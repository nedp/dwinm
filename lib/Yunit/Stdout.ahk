class YunitStdOut {
    update(category, test, result) {
        level := StrSplit(category, ".").length()

        static lastCategory := ""
        if (category != lastCategory) {
            categoryIndent := ""
            loop % level - 1 {
                categoryIndent .= "----"
            }
            FileAppend %categoryIndent%%category%:`n, *
            lastCategory := category
        }

        indent := ""
        if IsObject(result) {
            details := " at line " result.line " " result.message
            status := "FAIL"
            loop % level {
                indent .= "> > "
            }
        } else {
            details := ""
            status := "PASS"
            loop % level {
                indent .= "    "
            }
        }

        FileAppend, %indent%%status%: %test% %details%`n, *
    }
}
