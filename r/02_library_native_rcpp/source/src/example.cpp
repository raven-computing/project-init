${{VAR_COPYRIGHT_HEADER}}

#include <Rcpp.h>

using namespace Rcpp;


//' Adds the number 42 to each element of the specified numeric vector.
//'
//' Here we could give some more information about this
//' extraordinary function, but we think it's pretty self-explanatory.
//'
//' @param vec A numeric vector for which each element
//'            should be incremented by 42.
//'
//' @return A numeric vector with the same length as the input,
//'         but each element is incremented by 42.
//'
//' @details
//' This is pretty self-explanatory.
//'
//' @examples
//' \dontrun{
//' // This is a comment
//' x <- addVecFortyTwoNative(c(11, 22, 33, 44))
//' }
//'
//' @export
//'
// [[Rcpp::export]]
NumericVector addVecFortyTwoNative(NumericVector vec){
    NumericVector res(vec.length());
    for(int i=0; i<vec.length(); ++i){
        res[i] = vec[i] + 42;
    }
    return res;
}
