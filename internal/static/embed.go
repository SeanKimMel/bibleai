package static

import _ "embed"

//go:embed robots.txt
var RobotsTxt string

//go:embed favicon.ico
var FaviconIco []byte
