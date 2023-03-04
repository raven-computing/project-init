${{VAR_COPYRIGHT_HEADER}}

#' Adds the number 42 to the specified number.
#'
#' If only a single number is specifed, then the computation is done
#' in pure R code. If a vector of numbers with length greater
#' than 1 is specified, then the number 42 is added to each element
#' of the vector and the computation is performed in native code.
#'
#' @param num The number to add 42 to or a vector of numbers.
#'
#' @return The specified number plus 42 added to it or a
#'         numeric vector with the same length as the input and
#'         each element being plus 42.
#'
#' @details
#' This is pretty self-explanatory.
#'
#' @examples
#' \dontrun{
#' # This is a comment
#' x <- addFortyTwo(5)
#' y <- addFortyTwo(c(12, 34, 56))
#' }
#'
#' @export
#'
addFortyTwo <- function(num){
  if(!is.numeric(num)){
    stop("Argument must be numeric")
  }
  if(length(num) == 1){
    return(num + 42)
  }else{
    return(addVecFortyTwoNative(num))
  }
}

