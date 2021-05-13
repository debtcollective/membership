# Here we use Webpacker::Compiler to expose variables for the production build
Webpacker::Compiler.env["STRIPE_PUBLISHABLE_KEY"] = ENV["STRIPE_PUBLISHABLE_KEY"]
