require 'rails_helper'
require 'rake'

describe 'rake evaluation' do
  TRAINING_RAKE = 'import:training_data'
  TEST_RAKE = 'import:test_data'
  EVALUATE_RAKE = 'evaluation:evaluate'

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require 'tasks/import'
    Rake.application.rake_require 'tasks/evaluation'
    Rake::Task.define_task(:environment)
  end

  after(:all) do
    # clean manually
    DatabaseRewinder.clean
    FactoryGirl.reload
  end

  describe 'evaluation:evaluate' do
    let(:task) { EVALUATE_RAKE }

    context 'training' do
      folderpath = '/tmp/MC2-training'
      output_folderpath = '/tmp/'

      before :all do
        FileUtils.rm_r(folderpath) if Dir.exists?(folderpath)
        raise Exception.new("Downloaded file still exists") if Dir.exists?(folderpath)
        @rake[TRAINING_RAKE].invoke
      end

      before(:each) do
        @rake[task].reenable
      end

      it 'evaluate an English run' do
        filename = 'random_ranking_method.tsv'
        ENV['input_filepath'] = fixture_file("/runs/#{filename}")
        ENV['output_filepath'] = output_folderpath + filename
        ENV['runtype'] = 'training_retrieval_en'

        @rake[task].invoke

        csv = CSV.readlines(ENV['output_filepath'], 
          col_sep: "\t", headers: true)
        expect(csv["QID"].size).to be 100
        expect(csv["QID"][0]).to eq "1C2-E-0001"
        expect(csv["QID"][1]).to eq "1C2-E-0002"
        expect(csv["nDCG@20"][0].to_f).to almost_eq(0.9236489781475781, 4)
        expect(csv["nDCG@20"][1].to_f).to almost_eq(0.630978249951929, 4)
        expect(csv["Q"][0].to_f).to almost_eq(0.8696881789727421, 4)
        expect(csv["Q"][1].to_f).to almost_eq(0.7682962594599827, 4)
      end

      it 'evaluate a Japanese run' do
        filename = 'random_ranking_method_ja.tsv'
        ENV['input_filepath'] = fixture_file("/runs/#{filename}")
        ENV['output_filepath'] = output_folderpath + filename
        ENV['runtype'] = 'training_retrieval_ja'

        @rake[task].invoke

        csv = CSV.readlines(ENV['output_filepath'], 
          col_sep: "\t", headers: true)
        expect(csv["QID"].size).to be 100
        expect(csv["QID"][0]).to eq "1C2-J-0001"
        expect(csv["QID"][1]).to eq "1C2-J-0002"
        expect(csv["nDCG@20"][0].to_f).to almost_eq(0.4720255175107471, 4)
        expect(csv["nDCG@20"][1].to_f).to almost_eq(0.8800604075488622, 4)
        expect(csv["Q"][0].to_f).to almost_eq(0.7342344922051107, 4)
        expect(csv["Q"][1].to_f).to almost_eq(0.8427147025359145, 4)
      end
    end

    context 'test' do
      folderpath = '/tmp/MC2-test'
      output_folderpath = '/tmp/'

      before :all do
        FileUtils.rm_r(folderpath) if Dir.exists?(folderpath)
        raise Exception.new("Downloaded file still exists") if Dir.exists?(folderpath)
        @rake[TEST_RAKE].invoke
      end

      before(:each) do
        @rake[task].reenable
      end

      it 'evaluate an English retrieval run' do
        filename = 'test_random_ranking_method.tsv'
        ENV['input_filepath'] = fixture_file("/runs/#{filename}")
        ENV['output_filepath'] = output_folderpath + filename
        ENV['runtype'] = 'test_retrieval_en'

        @rake[task].invoke

        csv = CSV.readlines(ENV['output_filepath'], 
          col_sep: "\t", headers: true)
        expect(csv["QID"].size).to be 100
        expect(csv["QID"][0]).to eq "MC2-E-0001"
        expect(csv["QID"][1]).to eq "MC2-E-0002"
        expect(csv["nDCG@20"][0].to_f).to almost_eq(0.8753865151698038, 4)
        expect(csv["nDCG@20"][1].to_f).to almost_eq(0.7891240274287994, 4)
        expect(csv["Q"][0].to_f).to almost_eq(0.8953326522003913, 4)
        expect(csv["Q"][1].to_f).to almost_eq(0.8642639091579718, 4)
      end

      it 'evaluate a Japanese retrieval run' do
        filename = 'test_random_ranking_method_ja.tsv'
        ENV['input_filepath'] = fixture_file("/runs/#{filename}")
        ENV['output_filepath'] = output_folderpath + filename
        ENV['runtype'] = 'test_retrieval_ja'

        @rake[task].invoke

        csv = CSV.readlines(ENV['output_filepath'], 
          col_sep: "\t", headers: true)
        expect(csv["QID"].size).to be 100
        expect(csv["QID"][0]).to eq "MC2-J-0001"
        expect(csv["QID"][1]).to eq "MC2-J-0002"
        expect(csv["nDCG@20"][0].to_f).to almost_eq(0.6077189261896992, 4)
        expect(csv["nDCG@20"][1].to_f).to almost_eq(0.5928348735942018, 4)
        expect(csv["Q"][0].to_f).to almost_eq(0.7111040949703127, 4)
        expect(csv["Q"][1].to_f).to almost_eq(0.7461423235591332, 4)
      end

      it 'evaluate an English summarization run' do
        filename = 'random_summarization_method.xml'
        ENV['input_filepath'] = fixture_file("/runs/#{filename}")
        ENV['output_filepath'] = output_folderpath + filename
        ENV['runtype'] = 'test_summarization_en'

        @rake[task].invoke

        csv = CSV.readlines(ENV['output_filepath'], 
          col_sep: "\t", headers: true)
        expect(csv["QID"].size).to be 100
        expect(csv["QID"][0]).to eq "MC2-E-0001"
        expect(csv["QID"][1]).to eq "MC2-E-0002"
        expect(csv["M"][0].to_f).to almost_eq(19.64821113809524, 3)
        expect(csv["M"][1].to_f).to almost_eq(25.070873616666667, 3)
      end

      it 'evaluate a Japanese summarization run' do
        filename = 'random_summarization_method_ja.xml'
        ENV['input_filepath'] = fixture_file("/runs/#{filename}")
        ENV['output_filepath'] = output_folderpath + filename
        ENV['runtype'] = 'test_summarization_ja'

        @rake[task].invoke

        csv = CSV.readlines(ENV['output_filepath'], 
          col_sep: "\t", headers: true)
        expect(csv["QID"].size).to be 100
        expect(csv["QID"][0]).to eq "MC2-J-0001"
        expect(csv["QID"][1]).to eq "MC2-J-0002"
        expect(csv["M"][0].to_f).to almost_eq(14.66581195267857, 3)
        expect(csv["M"][1].to_f).to almost_eq(26.879433529464286, 3)
      end

    end
  end

end
