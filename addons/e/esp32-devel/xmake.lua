package("esp32-devel")
    set_kind("addon")
    set_homepage("https://github.com/xmake-addons/esp32-devel")
    set_description("The ESP32 development addon, it provides the toolchain, the build rules and the project templates of the esp32c3/esp32s3 boards.")
    set_license("Apache-2.0")

    add_urls("https://github.com/xmake-addons/esp32-devel/archive/refs/tags/$(version).tar.gz",
             "https://github.com/xmake-addons/esp32-devel.git")
    add_versions("v1.0.1", "8f9b142db3fcc588c82a6c06dea69ea82c894fca607b3e9f83735b2363f88489")

    add_deps("serial-tools", {kind = "addon"})

    on_test(function (package)
        assert(package:has_addon({
            rules      = "app",
            toolchains = "esp32",
            templates  = "c/esp32.hello"}))

        os.vrunv("xmake", {"create", "-t", "esp32.hello", "test"})
    end)
