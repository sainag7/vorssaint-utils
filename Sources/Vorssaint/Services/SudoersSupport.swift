// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

enum SudoersSupport {
    /// True when a `pmset -g` report lists lid sleep as disabled.
    static func sleepDisabled(inPmsetOutput output: String) -> Bool {
        output.range(of: #"SleepDisabled\s+1"#, options: .regularExpression) != nil
    }

    /// The closed-lid NOPASSWD rule, granted by uid (`#uid` user spec). A
    /// username would have to be sanitized against sudoers *and* shell
    /// metacharacters — short names on SSO-enrolled Macs can be full email
    /// addresses (#915) — while a uid interpolates as bare digits, which
    /// neither interpreter can read as anything else.
    static func clamshellRule(uid: uid_t) -> String {
        "#\(uid) ALL=(root) NOPASSWD: /usr/bin/pmset disablesleep 1, /usr/bin/pmset disablesleep 0"
    }

    /// The Low Power Mode NOPASSWD rule: only `pmset -a lowpowermode` 1 or 0,
    /// so the Power page's switch works without a password after the first.
    static func lowPowerRule(uid: uid_t) -> String {
        "#\(uid) ALL=(root) NOPASSWD: /usr/bin/pmset -a lowpowermode 1, /usr/bin/pmset -a lowpowermode 0"
    }
}
