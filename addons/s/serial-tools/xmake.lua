package("serial-tools")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/serial-tools")
    set_description("The serial port toolkit, it provides the `xmake monitor` command and the serial module.")

    add_urls("https://github.com/xmake-addons/serial-tools/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/serial-tools.git")
    add_versions("v1.0.2", "070441000e9817f7dcaaf956314a33c6e459d9c45047f16c975b0e642e7d36a2")

    on_test(function (package)
        assert(package:has_addon({plugins = "monitor", modules = "serial"}))

        os.vrun("xmake monitor --help")
        os.vrunv("xmake", {"lua", "-c", [[
            import("@addon.serial-tools.serial")
            assert(type(serial.ports()) == "table")
            assert(serial.monitor and serial.resolve_port)
        ]]})
    end)
