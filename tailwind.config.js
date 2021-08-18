module.exports = {
  purge: {
    content: [
      './app/**/*.html.erb',
      './app/helpers/**/*.rb',
      './app/javascript/**/*.js',
      './app/javascript/**/*.jsx',
    ],
  },
  theme: {
    extend: {
      colors: {
        lilac: '#D2C4F5',
      },
    },
  },
  variants: {},
  plugins: [require('@tailwindcss/forms')],
}
