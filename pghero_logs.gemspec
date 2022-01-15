require_relative "lib/pghero_logs/version"

Gem::Specification.new do |spec|
  spec.name          = "pghero_logs"
  spec.version       = PgheroLogs::VERSION
  spec.summary       = "Slow query log parser for Postgres"
  spec.homepage      = "https://github.com/ankane/pghero_logs"
  spec.license       = "MIT"

  spec.authors       = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib,exe}/**/*"]
  spec.require_path  = "lib"

  spec.bindir        = "exe"
  spec.executables   = ["pghero_logs"]

  spec.required_ruby_version = ">= 2.2"

  spec.add_dependency "pg_query"
  spec.add_dependency "aws-sdk", "~> 1"
end
