;; Event Creation Contract
;; Manages details of upcoming events and available seats

;; Data variables
(define-data-var event-counter uint u0)
(define-data-var venue-counter uint u0)
(define-data-var seat-category-counter uint u0)

;; Data maps
(define-map events
{ id: uint }
{
  name: (string-ascii 64),
  description: (string-ascii 256),
  venue-id: uint,
  start-date: uint,
  end-date: uint,
  organizer: principal,
  total-seats: uint,
  available-seats: uint,
  is-active: bool
}
)

(define-map venues
{ id: uint }
{
  name: (string-ascii 64),
  location: (string-ascii 128),
  capacity: uint,
  active: bool
}
)

(define-map seat-categories
{ id: uint }
{
  event-id: uint,
  name: (string-ascii 32),
  price: uint,
  total-seats: uint,
  available-seats: uint,
  active: bool
}
)

(define-map event-organizers
{ address: principal }
{ active: bool }
)

;; Initialize contract
(define-public (initialize)
(begin
  (map-set event-organizers { address: tx-sender } { active: true })
  (ok true)
)
)

;; Check if address is event organizer
(define-read-only (is-organizer (address principal))
(default-to false (get active (map-get? event-organizers { address: address })))
)

;; Add an event organizer
(define-public (add-organizer (address principal))
(begin
  ;; Only organizers can add organizers
  (asserts! (is-organizer tx-sender) (err u403))

  (map-set event-organizers
    { address: address }
    { active: true }
  )

  (ok true)
)
)

;; Register a venue
(define-public (register-venue (name (string-ascii 64)) (location (string-ascii 128)) (capacity uint))
(let ((new-id (+ (var-get venue-counter) u1)))
  ;; Only organizers can register venues
  (asserts! (is-organizer tx-sender) (err u403))

  ;; Update counter
  (var-set venue-counter new-id)

  ;; Store venue data
  (map-set venues
    { id: new-id }
    {
      name: name,
      location: location,
      capacity: capacity,
      active: true
    }
  )

  (ok new-id)
)
)

;; Create an event
(define-public (create-event
  (name (string-ascii 64))
  (description (string-ascii 256))
  (venue-id uint)
  (start-date uint)
  (end-date uint)
  (total-seats uint))
(let ((new-id (+ (var-get event-counter) u1))
      (venue (map-get? venues { id: venue-id })))

  ;; Only organizers can create events
  (asserts! (is-organizer tx-sender) (err u403))

  ;; Venue must exist
  (asserts! (is-some venue) (err u404))

  ;; Venue must be active
  (asserts! (get active (unwrap-panic venue)) (err u400))

  ;; Total seats must not exceed venue capacity
  (asserts! (<= total-seats (get capacity (unwrap-panic venue))) (err u400))

  ;; End date must be after start date
  (asserts! (> end-date start-date) (err u400))

  ;; Start date must be in the future
  (asserts! (> start-date block-height) (err u400))

  ;; Update counter
  (var-set event-counter new-id)

  ;; Store event data
  (map-set events
    { id: new-id }
    {
      name: name,
      description: description,
      venue-id: venue-id,
      start-date: start-date,
      end-date: end-date,
      organizer: tx-sender,
      total-seats: total-seats,
      available-seats: total-seats,
      is-active: true
    }
  )

  (ok new-id)
)
)

;; Create a seat category
(define-public (create-seat-category (event-id uint) (name (string-ascii 32)) (price uint) (total-seats uint))
(let ((new-id (+ (var-get seat-category-counter) u1))
      (event (map-get? events { id: event-id })))

  ;; Only organizers can create seat categories
  (asserts! (is-organizer tx-sender) (err u403))

  ;; Event must exist
  (asserts! (is-some event) (err u404))

  ;; Event must be active
  (asserts! (get is-active (unwrap-panic event)) (err u400))

  ;; Total seats in category must not exceed available event seats
  (asserts! (<= total-seats (get available-seats (unwrap-panic event))) (err u400))

  ;; Update counter
  (var-set seat-category-counter new-id)

  ;; Store seat category data
  (map-set seat-categories
    { id: new-id }
    {
      event-id: event-id,
      name: name,
      price: price,
      total-seats: total-seats,
      available-seats: total-seats,
      active: true
    }
  )

  ;; Update available seats in event
  (map-set events
    { id: event-id }
    (merge (unwrap-panic event)
      { available-seats: (- (get available-seats (unwrap-panic event)) total-seats) })
  )

  (ok new-id)
)
)

;; Update event status
(define-public (update-event-status (event-id uint) (is-active bool))
(let ((event (map-get? events { id: event-id })))

  ;; Only organizers can update event status
  (asserts! (is-organizer tx-sender) (err u403))

  ;; Event must exist
  (asserts! (is-some event) (err u404))

  ;; Only the event organizer can update its status
  (asserts! (is-eq tx-sender (get organizer (unwrap-panic event))) (err u403))

  ;; Store updated event
  (map-set events
    { id: event-id }
    (merge (unwrap-panic event) { is-active: is-active })
  )

  (ok true)
)
)

;; Update seat availability after ticket issuance
(define-public (update-seat-availability (category-id uint) (seats-sold uint))
(let ((category (map-get? seat-categories { id: category-id })))

  ;; Only ticket issuance contract can call this
  (asserts! (is-contract-caller (as-contract tx-sender)) (err u403))

  ;; Category must exist
  (asserts! (is-some category) (err u404))

  ;; Category must be active
  (asserts! (get active (unwrap-panic category)) (err u400))

  ;; Must have enough available seats
  (asserts! (>= (get available-seats (unwrap-panic category)) seats-sold) (err u400))

  ;; Store updated category
  (map-set seat-categories
    { id: category-id }
    (merge (unwrap-panic category)
      { available-seats: (- (get available-seats (unwrap-panic category)) seats-sold) })
  )

  (ok true)
)
)

;; Get event details
(define-read-only (get-event (event-id uint))
(map-get? events { id: event-id })
)

;; Get venue details
(define-read-only (get-venue (venue-id uint))
(map-get? venues { id: venue-id })
)

;; Get seat category details
(define-read-only (get-seat-category (category-id uint))
(map-get? seat-categories { id: category-id })
)

;; Get all seat categories for an event
(define-read-only (get-event-categories (event-id uint))
;; This is a simplified implementation
;; In a real contract, you would need to iterate through categories
(filter-categories event-id)
)

;; Check if event is active and in the future
(define-read-only (is-event-active (event-id uint))
(let ((event (map-get? events { id: event-id })))
  (and
    (is-some event)
    (get is-active (unwrap-panic event))
    (> (get start-date (unwrap-panic event)) block-height)
  )
)
)

;; Helper function to filter categories by event ID
;; In a real implementation, this would search through all categories
(define-read-only (filter-categories (event-id uint))
;; Placeholder implementation
(list)
)

;; Helper function to check if caller is a contract
(define-read-only (is-contract-caller (caller principal))
;; Placeholder implementation - in a real contract this would check if the caller is a known contract
true
)
