namespace :evaluation do

  def write_results(filepath, results)
    metrics = results.keys
    qids = results[metrics.first].keys.sort
    csv_data = CSV.generate col_sep: "\t" do |csv|
      csv << ["QID"] + metrics
      qids.each do |qid|
        csv << [qid] + metrics.map {|m| results[m][qid].to_s }
      end
    end
    File.open(filepath, 'w') do |f|
      f.write(csv_data)
    end
  end

  desc "Evaluate a run"
  task :evaluate => :environment do
    input_filepath = ENV['input_filepath']
    output_filepath = ENV['output_filepath']
    runtype = ENV['runtype']
    raise ArgumentError.new('input_filepath is not given') if input_filepath.nil?
    raise ArgumentError.new('output_filepath is not given') if output_filepath.nil?
    run = Run.new_run_instance(runtype: runtype, filepath: input_filepath)
    run.validate!

    results = run.evaluate

    write_results(output_filepath, results)
  end

end
