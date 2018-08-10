# Reads the specified secret paths (i.e. Docker Secrets) into environment
# variables:

# Process only a known list of env vars that can filled by reading a file (i.e.
# a docker secret):
%w(DATABASE_URL REDIS_URL).each do |key_to_write|
  key_to_write_exists = ENV.key?(key_to_write)

  file_key = "#{key_to_write}_FILE"
  file_key_exists = ENV.key?(file_key)

  if key_to_write_exists && file_key_exists
    STDERR.puts "Error: both '#{key_to_write}' and '#{key}' env variables are" \
                ' set, but are exclusive.'
    exit 1
  end

  next unless file_key_exists

  file_path = ENV[file_key]
  unless File.exist? file_path
    STDERR.puts "Error: '#{file_key}' env variable refers to a non-existant " \
                "file '#{file_path}'."
    exit 1
  end

  ENV[key_to_write] = File.read(file_path).strip
  ENV[file_key] = nil
end
