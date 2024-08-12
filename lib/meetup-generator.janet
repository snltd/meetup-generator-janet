(import spork/zip)
(import spork/json)
(import jdn)

(math/seedrandom (os/cryptorand 8))

(def location "Shoreditch, probably")

(defn load-words [file]
  (def raw-file (zip/read-file file))
  (string/split "\n" (string/trim (zip/extract raw-file 0))))

(defn load-things [file]
  (json/decode (slurp file) :keyword-keys))

(defn rand-between
  "Returns a random number between two given numbers, inclusive"
  [lower upper]
  (let [difference (- upper lower)
        rand-range (math/round (* (math/random) difference))]
    (+ lower rand-range)))

(defn sample
  "Returns a random element from the given list"
  [list]
  (if (> (length list) 0)
    (list (rand-between 0 (dec (length list))))
    nil))

(defn date
  "Returns dd/mm/YYYY tomorrow (usually)"
  []
  (os/strftime "%d/%m/%Y" (+ 86400 (os/time))))

(defn- pair
  [things first-key second-key]
  (string (sample (things first-key)) " " (sample (things second-key))))

(defn talker
  "Returns the name of a person doing a talk"
  [things]
  (pair things :first_name :last_name))

(defn job-title
  "Returns a pretentious job title"
  [things]
  (pair things :job_role :job_title))

(defn refreshment
  "Returns a pretentious thing to eat or drink"
  [things]
  (pair things :food_style :food))

(defn company
  "Returns a dot-io company name with the final vowel removed"
  [words]
  (string
    (peg/replace '(* (capture (set "bcdfghjklmnpqrstvwxyz") :cons) "er" -1)
                 |(string $1 "r") (sample words))
    ".io"))

(defn something-ops
  "Pairs 'Ops' with one of the prefix words"
  [things]
  (string (sample (things :something_ops)) "Ops"))

(defn ops-type
  "Return NoSlackGitOps or GitDevSlackOps or whatever. Non-repeating."
  [ops-things &opt result i]
  (default result "Ops")
  (default i 3)

  (if (= i 0)
    result
    (let [idx (rand-between 0 (dec (length ops-things)))
          word (ops-things idx)]
      (ops-type (array/remove ops-things idx) (string word result) (dec i)))))

(defn random-number
  "Returns a random number from a RAND100 type string"
  [str]
  (rand-between 1 (int/to-number (int/u64 (string/replace "RAND" "" str)))))

(defn replace-things
  "Populate a template string"
  [tmpl things words]

  (def replace-peg
    ~{:open-tag "<"
      :close-tag ">"
      :main (* :open-tag (capture (some :w+)) :close-tag)})

  (defn replacer
    [_ key]
    (def things-key (keyword key))
    (cond
      (string/has-prefix? "RAND" key) (random-number key)
      (= key "OPS") (ops-type (array ;(things :something_ops)))
      (= key "WORD") (sample words)
      (sample (things things-key))))

  (peg/replace-all replace-peg replacer tmpl))

(defn title
  "Return the title of a talk, from a template"
  [things words]
  (def tmpl (sample (things :template)))
  (replace-things tmpl things words))

(defn talk
  "Return a talk"
  [things words]
  {:title (title things words)
   :talker (talker things)
   :role (job-title things)
   :company (company words)
   :refreshment (refreshment things)})

(defn agenda
  "Return an agenda with the given number of talks"
  [things words number]
  (map (fn [_] (talk things words)) (range 0 number)))
