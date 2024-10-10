# frozen_string_literal: true

require "simplecov"
require "json"

class SimpleCovCheckActionFormatter
  SourceFile = Data.define(:source_file) do
    def covered_strength = source_file.covered_strength
    def covered_percent = source_file.covered_percent

    def to_json(*args)
      {
        filename: source_file.filename,
        covered_percent: covered_percent.nan? ? 0.0 : covered_percent,
        coverage: source_file.coverage_data,
        covered_strength: covered_strength.nan? ? 0.0 : covered_strength,
        covered_lines: source_file.covered_lines.count,
        lines_of_code: source_file.lines_of_code
      }.to_json(*args)
    end
  end

  Result = Data.define(:result) do
    def included?(source_file) = result.filenames.include?(source_file.filename)

    def files
      result.files.filter_map do |source_file|
        next unless result.filenames.include? source_file.filename

        SourceFile.new(source_file)
      end
    end

    def to_json(*args) # rubocop:disable Metrics/AbcSize
      {
        timestamp: result.created_at.to_i,
        command_name: result.command_name,
        files: files,
        metrics: {
          covered_percent: result.covered_percent,
          covered_strength: result.covered_strength.nan? ? 0.0 : result.covered_strength,
          covered_lines: result.covered_lines,
          total_lines: result.total_lines
        }
      }.to_json(*args)
    end
  end

  FormatterWithOptions = Data.define(:formatter) do
    def new = formatter
  end

  class << self
    def with_options(...)
      FormatterWithOptions.new(new(...))
    end
  end

  def initialize(output_filename: "coverage.json", output_directory: SimpleCov.coverage_path)
    @output_filename = output_filename
    @output_directory = output_directory
  end

  attr_reader :output_filename, :output_directory

  def output_filepath = File.join(output_directory, output_filename)

  def format(result_data)
    result = Result.new(result_data)
    json = JSON.generate(result)
    File.write(output_filepath, json)
    puts output_message(result_data)
    json
  end

  def output_message(result)
    "Coverage report generated for #{result.command_name} to #{output_filepath}. #{result.covered_lines} / #{result.total_lines} LOC (#{result.covered_percent.round(2)}%) covered." # rubocop:disable Layout/LineLength
  end
end
