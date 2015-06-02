# **cli.coffee** command line interface for the
# Smallest-Federated-Wiki express server

path = require 'path'

optimist = require 'optimist'
cc = require 'config-chain'
glob = require 'glob'
server = require 'wiki-server'

farm = require './farm'

getUserHome = ->
  process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE

# Handle command line options

argv = optimist
  .usage('Usage: $0')
  .options('url',
    alias     : 'u'
    describe  : 'Important: Your server URL, used as Persona audience during verification'
  )
  .options('port',
    alias     : 'p'
    describe  : 'Port'
  )
  .options('data',
    alias     : 'd'
    describe  : 'location of flat file data'
  )
  .options('root',
    alias     : 'r'
    describe  : 'Application root folder'
  )
  .options('farm',
    alias     : 'f'
    describe  : 'Turn on the farm?'
  )
  .options('home',
    describe  : 'The page to go to instead of index.html'
  )
  .options('host',
    alias     : 'o'
    describe  : 'Host to accept connections on, falsy == any'
  )
  .options('id',
    describe  : 'Set the location of the open id file'
  )
  .options('database',
    describe  : 'JSON object for database config'
  )
  .options('neighbors',
    describe  : 'comma separated list of neighbor sites to seed'
  )
  .options('autoseed',
    describe  : 'Seed all sites in a farm to each other site in the farm.'
    boolean   : true
  )
  .options('uploadLimit',
    describe  : 'Set the upload size limit, limits the size page content items, and pages that can be forked'
  )
  .options('test',
    boolean   : true
    describe  : 'Set server to work with the rspec integration tests'
  )
  .options('help',
    alias     : 'h'
    boolean   : true
    describe  : 'Show this help info and exit'
  )
  .options('config',
    alias     : 'conf'
    describe  : 'Optional config file.'
  )
  .options('version',
    alias     : 'v'
    describe  : 'Optional config file.'
  )
  .argv

config = cc(argv,
  argv.config,
  'config.json',
  path.join(__dirname, '..', 'config.json'),
  cc.env('wiki_'),
    port: 3000
    root: path.dirname(require.resolve('wiki-server'))
    home: 'welcome-visitors'
    data: path.join(getUserHome(), '.wiki') # see also defaultargs
    packageDir: path.resolve(path.join(__dirname, 'node_modules'))
).store

# If h/help is set print the generated help message and exit.
if argv.help
  optimist.showHelp()
# If v/version is set print the version of the wiki components and exit.
else if argv.version
  console.log('wiki: ' + require('./package').version)
  console.log('wiki-server: ' + require('wiki-server/package').version)
  console.log('wiki-client: ' + require('wiki-client/package').version)
  glob 'wiki-plugin-*', {cwd: config.packageDir}, (e, plugins) ->
    plugins.map (plugin) ->
      console.log(plugin + ': ' + require(plugin + '/package').version)

else if argv.test
  console.log "WARNING: Server started in testing mode, other options ignored"
  server({port: 33333, data: path.join(argv.root, 'spec', 'data')})
# If f/farm is set call../lib/farm.coffee with argv object, else call
# ../lib/server.coffee with argv object.
else if config.farm
  console.log('Wiki starting in Farm mode, navigate to a specific server to start it.')
  farm(config)
else
  app = server(config)
  app.on 'owner-set', (e) ->
    serv = app.listen app.startOpts.port, app.startOpts.host
    console.log "Smallest Federated Wiki server listening on", app.startOpts.port, "in mode:", app.settings.env
    app.emit 'running-serv', serv
