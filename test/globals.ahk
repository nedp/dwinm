class Logger {
}

"".base.__Get := "".base.__Set := "".base.__Call := Func("Default__Warn")

Default__Warn(nonobj, _*) {
    throw Exception("A non-object value was improperly invoked."
        . "`n`nSpecifically:"  %nonobj%, -2)
}
