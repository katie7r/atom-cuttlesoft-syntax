{SelectListView} = require 'atom-space-pen-views'

class CuttlesoftSelectListView extends SelectListView

  initialize: (@cuttlesoft) ->
    super
    @list.addClass 'mark-active'
    @setItems @getThemes()

  viewForItem: (theme) ->
    element = document.createElement 'li'
    if @cuttlesoft.isConfigTheme theme.style
      element.classList.add 'active'
    element.textContent = theme.name
    element

  getFilterKey: ->
    'name'

  selectItemView: (view) ->
    super
    theme = @getSelectedItem()
    @cuttlesoft.isPreview = true
    @cuttlesoft.enableTheme theme.style if @attached

  confirmed: (theme) ->
    @confirming = true
    @cuttlesoft.isPreview = false
    @cuttlesoft.isPreviewConfirmed = true
    @cuttlesoft.setThemeConfig theme.style
    @cancel()
    @confirming = false

  cancel: ->
    super
    @cuttlesoft.enableConfigTheme() unless @confirming
    @cuttlesoft.isPreview = false
    @cuttlesoft.isPreviewConfirmed = false

  cancelled: ->
    @panel?.destroy()

  attach: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @selectItemView @list.find 'li:last'
    @selectItemView @list.find '.active'
    @focusFilterEditor()
    @attached = true

  getThemes: ->
    if atom.config.get "#{@cuttlesoft.packageName}.matchUserInterfaceTheme"
      styles = [atom.config.defaultSettings["#{@cuttlesoft.packageName}"].style]
    else
      styles = atom.config.getSchema("#{@cuttlesoft.packageName}.style").enum
    themes = []
    # schemes.forEach (scheme) -> styles.forEach (style) ->
    #   themes.push scheme: scheme, style: style, name: "#{scheme} (#{style})"
    themes

module.exports = cuttlesoftSelectListView
