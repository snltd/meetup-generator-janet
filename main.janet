(use joy)
(import ./lib/meetup-generator)

(def words (meetup-generator/load-words "./lib/words.zip"))
(def things (meetup-generator/load-things "./lib/all_the_things.json"))

# Layout
(defn app-layout [{:body body :request request}]
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "meetup-generator"]
      [:meta {:charset "utf-8"}]
      [:meta {:name "viewport" :content "width=device-width, initial-scale=1"}]
      [:meta {:name "csrf-token" :content (csrf-token-value request)}]
      [:link {:href "/app.css" :rel "stylesheet"}]
      [:script {:src "/app.js" :defer ""}]]
     [:body
      body]]))


(route :get "/api/:item" :api)
(defn api
  [request]
  (application/json
    (case (keyword (get-in request [:params :item]))
      :agenda (meetup-generator/agenda things words 5)
      :talker (meetup-generator/talker things)
      :title (meetup-generator/title things words)
      :role (meetup-generator/job-title things)
      :company (meetup-generator/company words)
      :refreshment (meetup-generator/refreshment things)
      :talk (meetup-generator/talk things words)
      :date (meetup-generator/date)
      :location (meetup-generator/location things))))

(defn talk [start-time subtitle content]
  [:li start-time " // " subtitle
   [:span {:class "ttitle"} (content :title)]
   [:div {:class "indent"} (content :talker) " // "
    (content :role) " @ " (content :company)]])

(route :get "/*" :home)
(defn home [request]
  (def agenda (meetup-generator/agenda things words 5))
  (text/html
    (doctype :html5)
    [:html {:lang "en"}
     [:head
      [:title "#DevOps Meetup"]
      [:meta {:charset "utf-8"}]
      [:link {:href "/main.css" :rel "stylesheet"}]]
     [:body
      [:div {:id "container"}
       [:h1 "#DevOps Meetup // Shoreditch, probably // " (meetup-generator/date)]
       [:ul
        [:li "18:00 // Introduction"]
        (talk "18:10" "Lightning Talk // " (agenda 0))
        (talk "18:20" nil (agenda 1))
        [:li "18:50 // break"
         [:div {:class "indent"} (meetup-generator/refreshment things)]]
        (talk "19:20" nil (agenda 2))
        (talk "19:40" "Ignite // " (agenda 3))
        (talk "20:00" nil (agenda 4))
        [:li "20:30 // Close"
         [:div {:class "indent"}
          "Everyone is hiring, but no one's paying"]]] # close ul
       [:div {:id "footer"}
        [:a {:href "https://github.com/snltd/meetup-generator-clojure"}
         "The code"]]]]]))

(def app (-> (handler)
             (layout app-layout)
             (body-parser)
             (json-body-parser)
             (server-error)
             (x-headers)
             (static-files)
             (not-found)
             (logger)))

# Server
(defn main [& args]
  (let [port (get args 1 (os/getenv "PORT" "9001"))
        host (get args 2 "0.0.0.0")]
    (server app port host)))
