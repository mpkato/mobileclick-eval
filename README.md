# mobileclick-eval

[![Circle CI](https://circleci.com/gh/mpkato/mobileclick-eval.svg?&style=shield)](https://circleci.com/gh/mpkato/mobileclick-eval)

This project includes evaluation scripts for NTCIR-12 MobileClick-2.
This Ruby on Rails project is a part of the huge system hosted at
http://www.mobileclick.org/, and should return the same results as those
obtained through the website.

## Requirements
- Linux or Mac OS (or wherever Ruby and Rails work)
- Ruby (tested in 2.1.4)
- Bundler (tested in 1.9.4)
- gems listed in Gemfile


## Installation

### Clone this project

Please clone (or copy) this project into your PC:

```
git clone https://github.com/mpkato/mobileclick-eval.git
```

Then, you can move to this project directory 
```
cd mobileclick-eval
```

and stay at this directory during the following steps.


### Deploying evaluation data

To evaluate your MobileClick-2 runs, you need to obtain [NTCIR-12 MobileClick-2 Test Collection](http://research.nii.ac.jp/ntcir/permission/ntcir-12/perm-en-MobileClick.html) (you can easily obtain this test collection by applying at http://www.nii.ac.jp/dsc/idr/en/ntcir/ntcir.html ). 
`MC2-test-eval.tar.gz` should be put at the root directory of this project and be unpacked as follows:

```
tar fzxv MC2-test-eval.tar.gz
```

After unpacking the tar.gz file, your project should look like:
```
- mobileclick-eval
	- Gemfile
	- Gemfile.lock
	- MC2-test-eval
		- en
			- MC2-E-importance.tsv
			- MC2-E-probability.tsv
		- ja
			- MC2-J-importance.tsv
			- MC2-J-probability.tsv
	- README.md
	- Rakefile
	- app
	- bin
	- ...
```

### Installing Gems

Gems are Ruby libraries and can be installed through Bundler. Type the command below at `mobileclick-eval` directory for installing necessary gems:

```
bundle install --path vendor/bundle
```

Gems are installed at `vendor/bundle`. 
When you have any problems at the gem installation, please try to find solutions on the Web.


### DB initialization

mobileclick-eval stores the test collection into a SQLite file. Please initialize a SQLite file by the command below at `mobileclick-eval` directory:

```
bundle exec rake db:schema:load
```

If no error occurs, you are ready to load the MobileClick-2 test collection.
To load the data, please type the command shown below at `mobileclick-eval` directory:

```
bundle exec rake import:training_data
bundle exec rake import:test_data
```

## Usage

Now you are ready for evaluating your run files. Please refer to [Task page](http://www.mobileclick.org/home/task) for the detailed format of the output.

You can evaluate six types of runs:

- `training_retrieval_en` English iUnit Ranking (Training): Please generate an iUnit ranking run for a list of English queries in the training data.
- `training_retrieval_ja` Japanese iUnit Ranking (Training):Please generate an iUnit ranking run for a list of Japanese queries in the training data.
- `test_retrieval_en` English iUnit Ranking (Test):Please generate an iUnit ranking run for a list of English queries in the test data.
- `test_retrieval_ja` Japanese iUnit Ranking (Test): Please generate an iUnit ranking run for a list of Japanese queries in the test data.
- `test_summarization_en` English iUnit Summarization (Test): Please generate an iUnit summarization run for a list of English queries in the test data.
- `test_summarization_ja` Japanese iUnit Summarization (Test): Please generate an iUnit summarization run for a list of Japanese queries in the test data. 


Suppose you want to evaluate a `[runtype]` run stored in `[input_filepath]` and to output the evaluation result at `[output_filepath]`.
This can be achieved by

```
bundle exec rake evaluation:evaluate input_filepath=[input_filepath] output_filepath=[output_filepath] runtype=[runtype]
```

Recall that all the steps must be done at `mobileclick-eval` directory.


For example, you can test the installation by

```
be rake evaluation:evaluate input_filepath=./spec/fixtures/runs/random_ranking_method.tsv output_filepath=./result.tsv runtype=training_retrieval_en
```

Evaluation results are output at `result.tsv` in this example.

