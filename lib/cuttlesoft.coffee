fs = require 'fs'
path = require 'path'
{CompositeDisposable} = require 'atom'

class Cuttlesoft

  config: require('./cuttlesoft-settings').config

  activate: ->
    @disposables = new CompositeDisposable
    @packageName = require('../package.json').name
    if /light/.test atom.config.get('core.themes').toString()
      atom.config.setDefaults "#{@packageName}", style: 'Dark'
    @disposables.add atom.config.observe "#{@packageName}.style", => @enableConfigTheme()
    @disposables.add atom.commands.add 'atom-workspace', "#{@packageName}:select-theme", @createSelectListView

  deactivate: ->
    @disposables.dispose()

  enableConfigTheme: ->
    style = atom.config.get "#{@packageName}.style"
    @enableTheme style

  enableTheme: (style) ->
    # No need to enable the theme if it is already active.
    return if @isActiveTheme style unless @isPreviewConfirmed
    try
      # Write the requested theme to the `syntax-variables` file.
      fs.writeFileSync @getSyntaxVariablesPath(), @getSyntaxVariablesContent(style)
      activePackages = atom.packages.getActivePackages()
      if activePackages.length is 0 or @isPreview
        # Reload own stylesheets to apply the requested theme.
        atom.packages.getLoadedPackage("#{@packageName}").reloadStylesheets()
      else
        # Reload the stylesheets of all packages to apply the requested theme.
        activePackage.reloadStylesheets() for activePackage in activePackages
      @activeStyle = style
    catch
      # If unsuccessfull enable the default theme.
      @enableDefaultTheme()

  isActiveTheme: (style) ->
    style is @activeStyle

  getSyntaxVariablesPath: ->
    path.join __dirname, "..", "styles", "syntax-variables.less"

  getSyntaxVariablesContent: (style) ->
    """
    @style: '#{@getNormalizedName style}';

    @import 'colors';
    @import 'syntax-variables-@{style}';

    """

  getNormalizedName: (name) ->
    "#{name}"
      .replace ' ', '-'
      .toLowerCase()

  enableDefaultTheme: ->
    style = atom.config.getDefault "#{@packageName}.style"
    @setThemeConfig style

  setThemeConfig: (style) ->
    atom.config.set "#{@packageName}.style", style

  createSelectListView: =>
    CuttlesoftSelectListView = require './cuttlesoft-select-list-view'
    cuttlesoftSelectListView = new CuttlesoftSelectListView @
    cuttlesoftSelectListView.attach()

  isConfigTheme: (style) ->
    configStyle = atom.config.get "#{@packageName}.style"
    style is configStyle

module.exports = new Cuttlesoft
