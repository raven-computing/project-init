${{VAR_COPYRIGHT_HEADER}}

test_that("function addFortyTwo() works with integers", {
  x <- addFortyTwo(3)
  y <- addFortyTwo(0)
  z <- addFortyTwo(-3)
  expect_equal(x, 45)
  expect_equal(y, 42)
  expect_equal(z, 39)
})

test_that("function addFortyTwo() works with doubles", {
  x <- addFortyTwo(3.2)
  y <- addFortyTwo(0.0)
  z <- addFortyTwo(-3.2)
  expect_equal(x, 45.2)
  expect_equal(y, 42.0)
  expect_equal(z, 38.8)
})

