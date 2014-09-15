require "pghero_logs/version"
require "pg_query"
require "aws-sdk"

module PgHeroLogs
  class << self
    REGEX = /duration: (\d+\.\d+) ms  execute <unnamed>: (.+)?/i

    def run(command)
      case command
      when nil
        parse
      when "download"
        download
      else
        abort "Unknown command: #{command}"
      end
    end

    protected

    def download
      Dir.mkdir("logs") if !Dir.exists?("logs")

      db_instance_identifier = ENV["AWS_DB_INSTANCE_IDENTIFIER"]
      rds = AWS::RDS.new(access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
      resp = rds.client.describe_db_log_files(db_instance_identifier: db_instance_identifier)
      files = resp[:describe_db_log_files].map{|f| f[:log_file_name] }
      files.each do |log_file_name|
        local_file_name = log_file_name.sub("error", "logs")
        if File.exists?(local_file_name)
          puts "EXISTS #{local_file_name}"
        else
          data = ""
          marker = nil
          begin
            options = {
              db_instance_identifier: db_instance_identifier,
              log_file_name: log_file_name
            }
            options.merge!(marker: marker) if marker
            resp = rds.client.download_db_log_file_portion(options)
            data << resp[:log_file_data].to_s
          end while resp[:additional_data_pending] && (marker = resp[:marker])
          File.open(local_file_name, "w") { |file| file.write(data) }
          puts "DOWNLOADED #{local_file_name}"
        end
      end
    end

    def parse
      active_entry = ""
      $stdin.each_line do |line|
        if line.include?(":  ")
          if active_entry
            parse_entry(active_entry)
          end
          active_entry = ""
        end
        active_entry << line
      end
      parse_entry(active_entry)

      queries = self.queries.sort_by{|q, i| -i[:total_time] }[0...20]

      puts "Slowest Queries\n\n"
      puts "Total    Avg  Count  Query"
      puts "(min)   (ms)"
      queries.each do |query, info|
        puts "%5d  %5d  %5d  %s" % [info[:total_time] / 60000, info[:total_time] / info[:count], info[:count], query[0...60]]
      end

      puts "\nFull Queries\n\n"
      queries.each_with_index do |(query, info), i|
        puts "#{i + 1}. #{info[:sample]}"
        puts
      end
    end

    def parse_entry(active_entry)
      if (matches = active_entry.match(REGEX))
        begin
          query = PgQuery.normalize(squish(matches[2].gsub(/\/\*.+/, ""))).gsub(/\?(, \?)+/, "?")
          queries[query][:count] += 1
          queries[query][:total_time] += matches[1].to_f
          queries[query][:sample] = squish(matches[2])
        rescue PgQuery::ParseError
          # do nothing
        end
      end
    end

    def queries
      @queries ||= Hash.new {|hash, key| hash[key] = {count: 0, total_time: 0} }
    end

    def squish(str)
      str.gsub(/\A[[:space:]]+/, '').gsub(/[[:space:]]+\z/, '').gsub(/[[:space:]]+/, ' ')
    end

  end
end
