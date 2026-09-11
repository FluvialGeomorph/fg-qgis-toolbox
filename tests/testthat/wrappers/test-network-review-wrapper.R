# Direct-R integration is not a substitute for the provider's parser/transport.
test_that("network review matches the backend and preserves retained sources", {
  for (package in c("sf", "fluvgeo", "fluvgeodata", "rmarkdown")) {
    expect_true(requireNamespace(package, quietly = TRUE), info = package)
  }
  expect_true(rmarkdown::pandoc_available())
  # The workspace runner preloads spatial namespaces; their startup may set
  # GDAL_DATA. This suite tests adapter agreement with no inherited overrides.
  # Real fresh-process isolation is tested through the QGIS provider harness.
  withr::local_envvar(c(GDAL_DRIVER_PATH = NA, GDAL_DATA = NA,
                       PROJ_LIB = NA, PROJ_DATA = NA))
  script <- system.file("rscripts", "fg_review_stream_network.rsx",
                        package = "fgqgis", mustWork = TRUE)
  root <- tempfile("network review ")
  dir.create(root)
  withr::defer(unlink(root, recursive = TRUE))
  # Windows' C locale cannot translate Unicode paths in base::tempfile().
  # Qualify UTF-8 explicitly; this does not alter a user's provider environment.
  if (.Platform$OS.type == "windows") {
    withr::local_locale(c(LC_CTYPE = "English_United States.utf8"))
  }
  root <- file.path(root, "Cole Cr\u00e9ek")
  dir.create(root)
  streams <- data.frame(stream_id = "33333333-3333-4333-8333-333333333333",
    study_area_id = "11111111-1111-4111-8111-111111111111", stream_name = "Cole Creek")
  config <- fluvgeo::create_stream_network_configuration(
    "22222222-2222-4222-8222-222222222222", streams$study_area_id,
    "Test-only provisional configuration", "STREAM", streams, actor = "wrapper-test")
  # Only the 2006 archive retains stream_network; the companion flowline suite
  # exercises all three events. Do not invent networks for later events.
  for (year in 2006L) {
    archive <- system.file("extdata", paste0("y", year, "_R1.gdb"),
                           package = "fluvgeodata", mustWork = TRUE)
    sources <- list.files(archive, recursive = TRUE, full.names = TRUE)
    source_hashes <- tools::md5sum(sources)
    raw <- sf::st_read(archive, layer = "stream_network", quiet = TRUE)
    obs <- fluvgeo::create_stream_network_observation(
      "55555555-5555-4555-8555-555555555555",
      config$stream_network_configuration$stream_network_configuration_id,
      observation_year = year, evidence_class = "SOURCE_NETWORK_RETAINED",
      coverage_status = "PARTIAL_CONFIGURATION", derivation_method_id = "LEGACY_UNKNOWN",
      topology_tolerance = 0.01, topology_tolerance_unit = "METRE",
      native_horizontal_crs = "EPSG:26914", horizontal_unit = "METRE",
      provenance_completeness = "PARTIAL_LEGACY", actor = "wrapper-test")
    prepared <- fluvgeo::prepare_stream_network_from_features(raw,
      data.frame(source_row = seq_len(nrow(raw)), stream_id = streams$stream_id),
      config$stream_network_configuration, config$stream_network_configuration_stream,
      obs, actor = "wrapper-test")
    bundle <- c(config, list(stream_network_observation = obs), prepared)
    input <- file.path(root, paste0(year, " network.gpkg"))
    fluvgeo::write_stream_network_geodatabase(bundle, input)
    before <- tools::md5sum(input)
    direct <- fluvgeo::terrain_development_summary(network = input)
    output <- file.path(root, paste0(year, " report.html"))
    result <- run_rsx_fixture(script, list(INPUT = input, OUTPUT = output))
    # Fresh validation run IDs/timestamps legitimately differ across invocations.
    for (field in c("schema", "configuration", "observation", "segments", "gaps",
                    "assessment", "review_actions", "review_action_members")) {
      expect_equal(result$review[[field]], direct[[field]], info = field)
    }
    expect_identical(result$review$validation$stream_network_validation_run$result,
                     direct$validation$stream_network_validation_run$result)
    expect_true(is.null(result$review$study_area))
    expect_true(is.null(result$review$reaches))
    expect_equal(nrow(result$review$surveys), 0L)
    expect_true(any(grepl("not supplied", result$review$gaps)))
    expect_identical(result$OUTPUT, normalizePath(output, winslash = "/"))
    html <- readLines(output, warn = FALSE, encoding = "UTF-8")
    expect_true(any(grepl("study-structure", html, fixed = TRUE)))
    expect_gt(file.info(output)$size, 10000)
    output_hash <- tools::md5sum(output)
    expect_error(run_rsx_fixture(script, list(INPUT = input, OUTPUT = output)),
                 "already exists")
    expect_identical(tools::md5sum(output), output_hash)
    expect_error(run_rsx_fixture(script, list(INPUT = input, OUTPUT = input)),
                 "html")
    expect_identical(tools::md5sum(input), before)
    expect_identical(tools::md5sum(sources), source_hashes)
    # The new tool reopens supplied parent context, not a reconstructed hierarchy.
    reach <- data.frame(reach_id = "44444444-4444-4444-8444-444444444444",
      stream_id = streams$stream_id, reach_name = "R1")
    events <- data.frame(survey_event_id = c("66666666-6666-4666-8666-666666666666",
      "77777777-7777-4777-8777-777777777777", "88888888-8888-4888-8888-888888888888"),
      reach_id = reach$reach_id, survey_year = c(2006L, 2010L, 2016L))
    context_args <- list(study_area = data.frame(study_area_id = streams$study_area_id,
      study_area_name = "Papillion Creek"), streams = streams, reaches = reach,
      survey_events = events, analyst_notes = "Test-only provisional IDs; user-confirmed scope.")
    context <- do.call(fluvgeo::write_study_context, c(context_args,
      list(dsn = file.path(root, "study.gpkg"), network = basename(input))))
    context_before <- tools::md5sum(context)
    expected <- do.call(fluvgeo::terrain_development_summary, c(context_args, list(network = input)))
    study_script <- system.file("rscripts", "fg_review_study_area.rsx", package = "fgqgis", mustWork = TRUE)
    study_output <- file.path(root, "study review.html")
    actual <- run_rsx_fixture(study_script, list(INPUT = context, OUTPUT = study_output))
    reopened <- fluvgeo::read_study_context_summary(context)
    for (field in c("study_area", "streams", "reaches", "surveys", "event_evidence",
      "gaps", "assessment", "review_actions", "reconstruction"))
      expect_equal(reopened[[field]], expected[[field]], info = field)
    expect_equal(nrow(reopened$surveys), 3L)
    expect_true(file.exists(study_output))
    expect_error(run_rsx_fixture(study_script, list(INPUT = context, OUTPUT = study_output)), "already exists")
    expect_error(run_rsx_fixture(study_script, list(INPUT = input, OUTPUT = file.path(root, "no.html"))), "context binding")
    expect_false(file.exists(file.path(root, "no.html")))
    expect_identical(tools::md5sum(context), context_before)
    edit_script <- system.file("rscripts", "fg_revise_study_area.rsx", package = "fgqgis", mustWork = TRUE)
    edit_path <- file.path(root, "revised-study.gpkg")
    edit_report <- file.path(root, "revised-report.html")
    edit <- run_rsx_fixture(edit_script, list(INPUT = context, CONTEXT = edit_path,
      OUTPUT = edit_report, NEW_NAME = "", ADD_NOTE = "Test-only scope note: retained evidence remains provisional."))
    expect_true(file.exists(edit$CONTEXT) && file.exists(edit$OUTPUT))
    original_args <- fluvgeo::read_study_context(context)
    edited_args <- fluvgeo::read_study_context(edit$CONTEXT)
    expect_identical(edited_args$analyst_notes, paste(original_args$analyst_notes,
      "Test-only scope note: retained evidence remains provisional.", sep = "\n\n"))
    edited_args$analyst_notes <- original_args$analyst_notes
    expect_equal(edited_args, original_args)
    expect_error(run_rsx_fixture(edit_script, list(INPUT = context,
      CONTEXT = file.path(root, "noop.gpkg"), OUTPUT = file.path(root, "noop.html"),
      NEW_NAME = "", ADD_NOTE = "  ")), "No changes")
    expect_false(file.exists(file.path(root, "noop.gpkg")))
    expect_identical(tools::md5sum(context), context_before)
    expect_identical(tools::md5sum(input), before)
    expect_identical(tools::md5sum(sources), source_hashes)
  }
  missing_output <- file.path(root, "must-not-exist.html")
  expect_error(run_rsx_fixture(script,
    list(INPUT = file.path(root, "absent.gpkg"), OUTPUT = missing_output)))
  expect_false(file.exists(missing_output))
  # A readable single-layer GeoPackage is not a governed network bundle.
  plain <- file.path(root, "ordinary.gpkg")
  sf::st_write(raw, plain, layer = "raw", quiet = TRUE)
  expect_error(run_rsx_fixture(script, list(INPUT = plain, OUTPUT = missing_output)))
  expect_false(file.exists(missing_output))
})
