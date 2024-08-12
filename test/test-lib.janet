(use judge)
(import ../lib/meetup-generator :as lib)

(def sample-things
  {:first_name ["John"]
   :last_name ["Smith"]
   :job_role ["DevOps"]
   :job_title ["Ninja"]
   :food_style ["artistinal"]
   :food ["grazing boards"]
   :something_ops ["Test" "Test" "Test" "Test"]
   :tech ["Meetup Generator"]
   :template ["Test <tech> Things"]
   :verb ["Test"]
   :service ["DevOps"]
   :extreme ["Mazimize"]
   :quantifier ["Synergy"]
   :time ["Hours"]
   :driver ["Metric"]
   :adjective ["12 Factor"]
   :panacea ["Serverless"]
   :language ["Janet"]
   :skill_level ["n00b"]})

(def sample-words ["Prognosticater"])

(deftest "test-location"
  (test (= lib/location "Shoreditch, probably") true))

(deftest "test-load-words"
  (def words (lib/load-words "lib/words.zip"))
  (test (type words) :array)
  (test (words 999) "arclength")
  (test (length words) 19984))

(deftest "test-load-things"
  (def things (lib/load-things "lib/all_the_things.json"))
  (test (type things) :table)
  (test (keys things)
    @[:template
      :job_title
      :something_ops
      :tech
      :language
      :food
      :panacea
      :first_name
      :driver
      :job_role
      :time
      :service
      :last_name
      :quantifier
      :is_not
      :verb
      :adjective
      :skill_level
      :company
      :food_style
      :extreme]))

(deftest "test-sample"
  (test (lib/sample ["word"]) "word")
  (test (lib/sample []) nil)
  (test (has-value? ["b" "a"] (lib/sample ["a" "b"])) true))

(deftest "test-date"
  (test
    (peg/match
      '(sequence (set "0123") :d "/" (set "012") :d "/" "2" "0" :d :d -1)
      (lib/date))
    @[]))

(deftest "test thing makers"
  (test (lib/talker sample-things) "John Smith")
  (test (lib/job-title sample-things) "DevOps Ninja")
  (test (lib/refreshment sample-things) "artistinal grazing boards")
  (test (lib/something-ops sample-things) "TestOps"))

(deftest "test company names"
  (test (lib/company ["merp"]) "merp.io")
  (test (lib/company ["merper"]) "merpr.io")
  (test (lib/company ["leadswinger"]) "leadswingr.io")
  (test (lib/company ["wear"]) "wear.io"))

(deftest "test something-ops"
  (test (lib/something-ops sample-things) "TestOps"))

(deftest "test replace-things"
  (test (lib/replace-things "<tech> your <tech>" sample-things sample-words)
        @"Meetup Generator your Meetup Generator")
  (test (lib/replace-things "<adjective> <tech> for Fun" sample-things sample-words)
        @"12 Factor Meetup Generator for Fun")
  (test (lib/replace-things "<driver> Driven Development 101" sample-things sample-words)
        @"Metric Driven Development 101")
  (test (lib/replace-things "How we <verb>ed <tech> with <tech> in <RAND1> <time>" sample-things sample-words)
        @"How we Tested Meetup Generator with Meetup Generator in 1 Hours")
  (test (lib/replace-things "<panacea> Will Fix Everything" sample-things sample-words)
        @"Serverless Will Fix Everything")
  (test (lib/replace-things "From <OPS> to <OPS>" sample-things sample-words)
        @"From TestTestTestOps to TestTestTestOps"))

(deftest "test ops-type"
  (def result (lib/ops-type @["Dev" "Git" "No"]))
  (test (length result) 11))

(deftest "test title"
  (test (lib/title sample-things sample-words) @"Test Meetup Generator Things"))

(deftest "test talk"
  (test (lib/talk sample-things sample-words)
        {:company "Prognosticatr.io"
         :refreshment "artistinal grazing boards"
         :role "DevOps Ninja"
         :talker "John Smith"
         :title @"Test Meetup Generator Things"}))

(deftest "test agenda"
  (test (lib/agenda sample-things sample-words 2)
        @[{:company "Prognosticatr.io"
           :refreshment "artistinal grazing boards"
           :role "DevOps Ninja"
           :talker "John Smith"
           :title @"Test Meetup Generator Things"}
          {:company "Prognosticatr.io"
           :refreshment "artistinal grazing boards"
           :role "DevOps Ninja"
           :talker "John Smith"
           :title @"Test Meetup Generator Things"}]))
