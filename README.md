# Headcount

This version of the project parses through, stores, and analyzes select data from 11 public CSV files containing information on enrollment, standardized test performance, and economic data of public school students for districts in Colorado.

Via the creation of four separate repositories--District, Enrollment, StatewideTest, and EconomicProfile--district data is stored in its appropriate category and accessed for analysis via the District Repository. Each repository is comprised of its respective objects and can be loaded into and accessed independently.

## Usage
### Loading Data

Interaction is intended via pry or irb (or any similar tool). To load and store all data into the appropriate repositories, first load `./lib/district_repository.rb` and create a new instance of `DistrictRepository`:

```
load './lib/district_repository.rb'
dr = DistrictRepository.new
```

Immediately following this command, you can load all of the data from the CSV files:

```
dr.load_data({
  :enrollment => {
    :kindergarten => "./data/Kindergartners in full-day program.csv",
    :high_school_graduation => "./data/High school graduation rates.csv",
  },
  :statewide_testing => {
    :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
    :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
    :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
    :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
    :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
  },
  :economic_profile => {
    :median_household_income => "./data/Median household income.csv",
    :children_in_poverty => "./data/School-aged children in poverty.csv",
    :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
    :title_i => "./data/Title I students.csv"
  }
})
```

### Accessing Data

To view all data from any one district, call `find_by_district`. This method takes a string argument and searches through all districts case-insensitively.

```
dr.find_by_name("Academy 20")
```

More reasonable amounts of data can be found by tapping into each respective repository and its methods.

**Please note that all methods below must be chained on to `dr.find_by_name`.**

#### Enrollment Data
**All enrollment data is accessed by first appending `.enrollment` to `dr.find_by_name`**.

* `kindergarten_participation` returns raw data for each year available regarding the percentage of students enrolled in kindergarten.
* `kindergarten_participation_by_year` returns truncated percentages that are sorted by year.
* `kindergarten_participation_in_year(year)` takes an integer as an argument for the requested year and returns a truncated float of percentage from that year.
* `high_school_graduation` returns raw data for each year available regarding the percentage of students that graduate from high school.
* `graduation_rate_by_year` returns truncated percentages that are sorted by year.
* `graduation_rate_in_year(year)` takes an integer as an argument for the requested year and returns a truncated float of percentage from that year.

#### Statewide Testing Data
**All statewide testing data is accessed by first appending `.statewide_test` to `dr.find_by_name`**.

* `proficient_by_grade(grade)` takes an integer as an argument for the requested grade level (_note: 3 and 8 are the only valid options_) and returns truncated float percentages for math, reading, and writing sorted by year.
* `proficient_for_subject_by_grade_in_year(subject, grade, year)` takes three arguments: `subject` as a symbol (`:math`, `:reading`, or `:writing`), `grade` as an integer (`3` or `8`), and year as an integer (e.g., `2007`). Returns the percentage as a truncated float.
* `proficient_by_race_or_ethnicity(race_or_ethnicity)` takes a symbol as an argument for the requested race or ethnicity (_note: :all_students, :asian, :black, :pacific_islander, :hispanic, :native_american, :two_or_more, and :white are the only valid options_) and returns truncated float percentages for math, reading, and writing sorted by year.
* `proficient_for_subject_by_race_in_year(subject, race, year)` takes three arguments: `subject` as a symbol (`:math`, `:reading`, or `:writing`), `race` as a symbol (`:all_students`, `:asian`, `:black`, `:pacific_islander`, `:hispanic`, `:native_american`, `:two_or_more`, or `:white`), and year as an integer (e.g., `2007`). Returns the percentage as a truncated float.

#### Economic Profile Data
**All economic profile data is accessed by first appending `.economic_profile` to `dr.find_by_name`**.

* `median_household_income_in_year(year)` takes an integer as the argument for the requested year and returns an integer for the dollar amount.
* `median_household_income_average` returns an integer for the dollar amount average across all available years.
* `children_in_poverty_in_year(year)` takes an integer as the argument for the requested year and returns the percentage as a truncated float.
* `free_or_reduced_price_lunch_percentage_in_year(year)` takes an integer as the argument for the requested year and returns the percentage of students eligible as a truncated float.
* `free_or_reduced_price_lunch_number_in_year(year)` takes an integer as the argument for the requested year and returns the number of students eligible as an integer.
* `title_i_in_year(year)` takes an integer as the argument for the requested year and returns the percentage of Title I students as a truncated float.

### Performing Analysis
**Analysis requires the creation of an instance of Headcount Analyst, which we'll pass our District Repository (`dr`) into. All methods below will be called on this instance of Headcount Analyst.**

```
ha = HeadcountAnalyst.new(dr)
```

* `kindergarten_participation_rate_variation(district, :against => other_district)` takes strings as the arguments for `district` and `other_district` and returns a truncated float that represents `district`'s average participation rate across all years divided by `other_district`'s average participation rate across all years. A value lower than 1 indicates that `district` has higher kindergarten participation than `other_district`, while a number higher than 1 indicates the reverse. A comparison can also be made against statewide data by assigning `other_district` to `"Colorado"`.
* `kindergarten_participation_rate_variation_trend(district, :against => other_district)` Operates similarly to the above method but is intended to only have `other_district` assigned to `"Colorado"` for a statewide comparison. Returns data sorted by year.
