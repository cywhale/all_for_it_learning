//https://github.com/preactjs/preact-cli/issues/224
export default (props) => {
  const { options } = props.htmlWebpackPlugin;
  const { files } = props.htmlWebpackPlugin;
  const { chunks } = props.webpack
  const polyfillsEntry = files.chunks['polyfills'].entry;
  const polyfillsScript = `window.fetch || document.write('<script src="${polyfillsEntry}"><\\/script>')`

  const handleChunks = () => {
    for (let chunk of chunks) {
      if (chunk.names.length === 1 && chunk.names[0] === 'polyfills') continue;
      for (let file of chunk.files) {
        if (options.preload && file.match(/\.(js|css)$/)) {
          <link rel='preload' href={files.publicPath + file} as={file.match(/\.css$/) ? 'style' : 'script'} />
        }
        else if (file.match(/manifest\.json$/)) {
          <link rel='manifest' href={ files.publicPath + file } />
        }
      }
    }
  };

  return(
    <html lang="en">
      <head>
                <meta charset="utf-8" />
                <title>Try Preact</title>
                <meta name="viewport" content="width=device-width,initial-scale=1" />
                <meta name="mobile-web-app-capable" content="yes" />
                <meta name="apple-mobile-web-app-capable" content="yes" />
                <link rel="apple-touch-icon" href="/assets/icons/apple-touch-icon.png" />
        { options.manifest.theme_color && <meta name='theme-color' content={options.manifest.theme_color} /> }
        { handleChunks() }
      </head>
      <body>
        { options.ssr({ url: '/' }) }
        <script defer src={ files.chunks['bundle'].entry }></script>
        <script dangerouslySetInnerHTML={{ __html: polyfillsScript }}></script>
      </body>
    </html>
  );
}
