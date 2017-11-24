settings =
  config:
    style:
      type: 'string'
      default: 'Dark'
      enum: ['Dark', 'Light']
    matchUserInterfaceTheme:
      type: 'boolean'
      default: true
      description: "When enabled the style will be matched to the current UI theme by default."

module.exports = settings
