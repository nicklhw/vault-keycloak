{{ with secret "secret/app1" }}
<html>
<head>
</head>
  <body>
    <li><strong>foo</strong> &#58; {{ .Data.data.foo }}</li>
    <li><strong>zip</strong> &#58; {{ .Data.data.zip }}</li>
</body>
</html>
{{ end }}
