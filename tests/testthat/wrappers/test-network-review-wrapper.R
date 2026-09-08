# Direct-R integration is not a substitute for the provider's parser/transport.
test_that("network review matches the backend and preserves retained sources", {
  for (package in c("sf", "fluvgeo", "fluvgeodata", "rmarkdown")) {
    expect_true(requireNamespace(package, quietly = TRUE), info = package)
  }
  expect_true(rmarkdown::pandoc_available())
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
