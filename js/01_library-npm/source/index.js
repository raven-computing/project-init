${{VAR_COPYRIGHT_HEADER}}

module.exports = function addFortyTwo(num) {
    if (typeof num !== "number") {
        throw new TypeError(
            "Invalid argument: Expected number but found '"
            + typeof num + "'"
        );
    }
    return num + 42;
};

