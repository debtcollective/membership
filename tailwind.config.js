module.exports = {
  purge: {
    content: [
      './app/**/*.html.erb',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js',
      './app/javascript/**/*.jsx'
    ]
  },
  theme: {},
  variants: {},
  plugins: [require('@tailwindcss/forms')]
}
