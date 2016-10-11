require 'rails_helper'

RSpec.describe Summary, type: :model do
  describe ".read" do

    context "with valid file" do
      let(:file) { fixture_file_upload("/runs/test_summarization_en.xml") }
      it { expect{Summary.read(file)}.not_to raise_error }
    end

    context "with invalid xml format file" do
      context "of premature end" do
        let(:file) { fixture_file_upload("/runs/test_summarization_en_premature_end.xml") }
        it { expect{Summary.read(file)}.to raise_error(SummaryError) }
      end
      context "of bad attributes" do
        let(:file) { fixture_file_upload("/runs/test_summarization_en_bad_attributes.xml") }
        it { expect{Summary.read(file)}.to raise_error(SummaryError) }
      end
      context "of bad tag match" do
        let(:file) { fixture_file_upload("/runs/test_summarization_en_bad_tag_match.xml") }
        it { expect{Summary.read(file)}.to raise_error(SummaryError) }
      end
    end

    context "with invalid xml file" do
      context "of no root" do
        let(:file) { fixture_file_upload("/runs/test_summarization_en_no_root.xml") }
        it { expect{Summary.read(file)}.to raise_error(SummaryError) }
      end
      context "of no sysdesc" do
        let(:file) { fixture_file_upload("/runs/test_summarization_en_no_sysdesc.xml") }
        it { expect{Summary.read(file)}.to raise_error(SummaryError) }
      end
      context "of no first" do
        let(:file) { fixture_file_upload("/runs/test_summarization_en_no_first.xml") }
        it { expect{Summary.read(file)}.to raise_error(SummaryError) }
      end
      context "of invalid tag" do
        let(:file) { fixture_file_upload("/runs/test_summarization_en_invalid_tag.xml") }
        it { expect{Summary.read(file)}.to raise_error(SummaryError) }
      end
      context "of invalid attribute" do
        let(:file) { fixture_file_upload("/runs/test_summarization_en_invalid_attribute.xml") }
        it { expect{Summary.read(file)}.to raise_error(SummaryError) }
      end
    end

  end
end

