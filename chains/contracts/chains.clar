;; ChainLens - Stacks Analytics Dashboard Smart Contract
;; This contract collects and stores analytics data for the Stacks blockchain

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-DATA (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-NOT-FOUND (err u103))

;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; Data structures for analytics
(define-map protocol-metrics
  { protocol-id: uint }
  {
    name: (string-ascii 64),
    total-value-locked: uint,
    daily-volume: uint,
    transaction-count: uint,
    unique-users: uint,
    last-updated: uint
  }
)

(define-map daily-stats
  { date: uint }
  {
    total-transactions: uint,
    total-volume: uint,
    active-protocols: uint,
    new-users: uint,
    gas-fees-collected: uint
  }
)

(define-map user-analytics
  { user: principal }
  {
    total-transactions: uint,
    total-volume: uint,
    first-seen: uint,
    last-active: uint,
    favorite-protocols: (list 10 uint)
  }
)

;; Track protocol registry
(define-data-var next-protocol-id uint u1)
(define-data-var total-protocols uint u0)

;; Events
(define-data-var last-update-block uint u0)

;; Admin functions
(define-public (add-protocol (name (string-ascii 64)))
  (let
    (
      (protocol-id (var-get next-protocol-id))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-DATA)
    
    (map-set protocol-metrics
      { protocol-id: protocol-id }
      {
        name: name,
        total-value-locked: u0,
        daily-volume: u0,
        transaction-count: u0,
        unique-users: u0,
        last-updated: block-height
      }
    )
    
    (var-set next-protocol-id (+ protocol-id u1))
    (var-set total-protocols (+ (var-get total-protocols) u1))
    
    (ok protocol-id)
  )
)

(define-public (update-protocol-metrics 
  (protocol-id uint)
  (tvl uint)
  (volume uint)
  (tx-count uint)
  (users uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? protocol-metrics { protocol-id: protocol-id })) ERR-NOT-FOUND)
    
    (match (map-get? protocol-metrics { protocol-id: protocol-id })
      protocol-data 
      (begin
        (map-set protocol-metrics
          { protocol-id: protocol-id }
          (merge protocol-data {
            total-value-locked: tvl,
            daily-volume: volume,
            transaction-count: tx-count,
            unique-users: users,
            last-updated: block-height
          })
        )
        (ok true)
      )
      ERR-NOT-FOUND
    )
  )
)

(define-public (record-daily-stats
  (date uint)
  (total-tx uint)
  (total-vol uint)
  (active-protos uint)
  (new-users uint)
  (gas-fees uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    
    (map-set daily-stats
      { date: date }
      {
        total-transactions: total-tx,
        total-volume: total-vol,
        active-protocols: active-protos,
        new-users: new-users,
        gas-fees-collected: gas-fees
      }
    )
    
    (var-set last-update-block block-height)
    (ok true)
  )
)

(define-public (update-user-analytics
  (user principal)
  (tx-count uint)
  (volume uint)
  (protocols (list 10 uint)))
  (let
    (
      (existing-data (default-to
        {
          total-transactions: u0,
          total-volume: u0,
          first-seen: block-height,
          last-active: block-height,
          favorite-protocols: (list)
        }
        (map-get? user-analytics { user: user })
      ))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    
    (map-set user-analytics
      { user: user }
      {
        total-transactions: tx-count,
        total-volume: volume,
        first-seen: (get first-seen existing-data),
        last-active: block-height,
        favorite-protocols: protocols
      }
    )
    
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-protocol-metrics (protocol-id uint))
  (map-get? protocol-metrics { protocol-id: protocol-id })
)

(define-read-only (get-daily-stats (date uint))
  (map-get? daily-stats { date: date })
)

(define-read-only (get-user-analytics (user principal))
  (map-get? user-analytics { user: user })
)

(define-read-only (get-total-protocols)
  (var-get total-protocols)
)

(define-read-only (get-last-update-block)
  (var-get last-update-block)
)

;; Analytics aggregation functions
(define-read-only (get-protocol-list (start-id uint) (limit uint))
  (let
    (
      (end-id (+ start-id limit))
    )
    (map get-protocol-metrics-by-id (list start-id (+ start-id u1) (+ start-id u2) (+ start-id u3) (+ start-id u4)))
  )
)

(define-private (get-protocol-metrics-by-id (id uint))
  {
    protocol-id: id,
    data: (map-get? protocol-metrics { protocol-id: id })
  }
)

;; Public data submission (for external oracles/indexers)
(define-public (submit-transaction-data
  (user principal)
  (protocol-id uint)
  (volume uint)
  (gas-used uint))
  (let
    (
      (existing-user (default-to
        {
          total-transactions: u0,
          total-volume: u0,
          first-seen: block-height,
          last-active: block-height,
          favorite-protocols: (list)
        }
        (map-get? user-analytics { user: user })
      ))
    )
    ;; Update user analytics
    (map-set user-analytics
      { user: user }
      {
        total-transactions: (+ (get total-transactions existing-user) u1),
        total-volume: (+ (get total-volume existing-user) volume),
        first-seen: (get first-seen existing-user),
        last-active: block-height,
        favorite-protocols: (get favorite-protocols existing-user)
      }
    )
    
    (ok true)
  )
)