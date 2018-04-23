package sql

import (
	mysql "database/sql"
	"fmt"
	"math"

	"github.com/btoll/cpss/server/app"
)

type BillSheet struct {
	Data interface{}
	Stmt map[string]string
}

func NewBillSheet(payload interface{}) *BillSheet {
	return &BillSheet{
		Data: payload,
		Stmt: map[string]string{
			"DELETE": "DELETE FROM billsheet WHERE id=?",
			"INSERT": "INSERT billsheet SET specialist=?,consumer=?,hours=?,units=?,serviceDate=?,serviceCode=?,hold=?,contractType=?,recipientID=?,recordNumber=?,status=?,billedCode=?,billedAmount=?,county=?,confirmation=?,description=?",
			"SELECT": "SELECT %s FROM billsheet %s",
			"UPDATE": "UPDATE billsheet SET specialist=?,consumer=?,hours=?,units=?,serviceDate=?,serviceCode=?,hold=?,contractType=?,recipientID=?,recordNumber=?,status=?,billedCode=?,billedAmount=?,county=?,confirmation=?,description=? WHERE id=?",
		},
	}
}

func updateConsumerUnits(id int, unitsToDecrement float64, db *mysql.DB) error {
	rows, err := db.Query(fmt.Sprintf("SELECT units FROM consumer WHERE id=%d", id))
	if err != nil {
		return err
	}
	var currentUnits float64
	for rows.Next() {
		err := rows.Scan(&currentUnits)
		if err != nil {
			return err
		}
	}
	stmt, err := db.Prepare("UPDATE consumer SET units=? WHERE id=?")
	if err != nil {
		return err
	}
	newUnits := currentUnits - unitsToDecrement
	if newUnits < 0 {
		newUnits = 0
	}
	_, err = stmt.Exec(newUnits, id)
	return err
}

func updateHold(db *mysql.DB, id int) error {
	// There is already a prior entry for this consumer with the same ServiceDate and ServiceCode, so we need to remove the hold.
	stmt, err := db.Prepare("UPDATE billsheet SET hold=? WHERE id=?")
	if err != nil {
		return err
	}
	_, err = stmt.Exec(0, id)
	if err != nil {
		return err
	}
	fmt.Printf("Removed hold from billsheet, record #%d\n", id)
	return nil
}

/**
 * This method checks for a prior hold marked by an IC.
 * A hold means that an IC created a Time Entry that same day for the same consumer for the same service code.
 * Leta needs to know when this happens so she doesn't submit the time for billing when it's not yet complete.
 * We search the records for consumer AND serviceDate AND serviceCode, but the UI needs to know when a record
 * has been marked as a hold so Leta knows.
 *
 * It returns the record ID if there is one match so we can then flip the hold bit to false.
 * Else it returns the number of matches.
 */
func (s *BillSheet) CheckForHold(db *mysql.DB, payload *app.BillSheetPayload) (int, int) {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "id, COUNT(*)", fmt.Sprintf("WHERE consumer=%d AND serviceDate='%s' AND serviceCode=%d", payload.Consumer, payload.ServiceDate, payload.ServiceCode)))
	if err != nil {
		return -1, -1
	}
	var id int
	var count int
	for rows.Next() {
		err = rows.Scan(&id, &count)
		if err != nil {
			return -1, -1
		}
	}
	if count == 1 {
		return count, id
	}
	return count, -1
}

func (s *BillSheet) CollectRows(rows *mysql.Rows, coll []*app.BillSheetItem) error {
	i := 0
	for rows.Next() {
		var id int
		var specialist int
		var consumer int
		var hours float64
		var units float64
		var serviceDate string
		var serviceCode int
		var hold bool
		var contractType string
		var recipientID string
		var recordNumber string
		var status int
		var billedCode string
		var billedAmount float64
		var county int
		var confirmation string
		var description string
		err := rows.Scan(&id, &specialist, &consumer, &hours, &units, &serviceDate, &serviceCode, &hold, &contractType, &recipientID, &recordNumber, &status, &billedCode, &billedAmount, &county, &confirmation, &description)
		if err != nil {
			return err
		}
		coll[i] = &app.BillSheetItem{
			ID:           id,
			Specialist:   specialist,
			Consumer:     consumer,
			Hours:        &hours,
			Units:        &units,
			ServiceDate:  serviceDate,
			ServiceCode:  serviceCode,
			Hold:         hold,
			ContractType: &contractType,
			RecipientID:  &recipientID,
			RecordNumber: &recordNumber,
			Status:       &status,
			BilledCode:   &billedCode,
			BilledAmount: &billedAmount,
			County:       county,
			Confirmation: &confirmation,
			Description:  &description,
		}
		i++
	}
	return nil
}

func (s *BillSheet) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.BillSheetPayload)
	// First, check if there is a previous hold placed by another IC.
	count, id := s.CheckForHold(db, payload)
	if count > 1 {
		return nil, fmt.Errorf("Consumer already has two entries on %s with code %d, aborting.  Please see Leta.", payload.ServiceDate, payload.ServiceCode)
	} else if count != 0 {
		err := updateHold(db, id)
		if err != nil {
			return nil, err
		}
	}
	// For now, don't update the billsheet table if the update on consumer fails!
	// 4 units per hour!
	err := updateConsumerUnits(payload.Consumer, *payload.Hours*4, db)
	if err != nil {
		return nil, err
	}
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Specialist, payload.Consumer, payload.Hours, payload.Units, payload.ServiceDate, payload.ServiceCode, payload.Hold, payload.ContractType, payload.RecipientID, payload.RecordNumber, payload.Status, payload.BilledCode, payload.BilledAmount, payload.County, payload.Confirmation, payload.Description)
	if err != nil {
		return -1, err
	}
	var lastID int64
	lastID, err = res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return int(lastID), nil
}

func (s *BillSheet) Delete(db *mysql.DB) error {
	stmt, err := db.Prepare(s.Stmt["DELETE"])
	if err != nil {
		return err
	}
	id := s.Data.(int)
	_, err = stmt.Exec(&id)
	return err
}

func (s *BillSheet) List(db *mysql.DB) (interface{}, error) {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", ""))
	if err != nil {
		return nil, err
	}
	var count int
	for rows.Next() {
		err = rows.Scan(&count)
		if err != nil {
			return nil, err
		}
	}
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", ""))
	if err != nil {
		return nil, err
	}
	coll := make([]*app.BillSheetItem, count)
	err = s.CollectRows(rows, coll)
	if err != nil {
		return nil, err
	}
	return coll, nil
}

func (s *BillSheet) Page(db *mysql.DB) (interface{}, error) {
	// page * RecordsPerPage = limit
	query := s.Data.(*PageQuery)
	limit := query.Page * RecordsPerPage
	whereClause := ""
	if query.WhereClause != "" {
		whereClause = fmt.Sprintf("WHERE %s", query.WhereClause)
	}
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", whereClause))
	if err != nil {
		return nil, err
	}
	var totalCount int
	for rows.Next() {
		err = rows.Scan(&totalCount)
		if err != nil {
			return nil, err
		}
	}
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", fmt.Sprintf("%s LIMIT %d,%d", whereClause, limit, RecordsPerPage)))
	if err != nil {
		return nil, err
	}
	// Only get the amount of rows equal to RecordsPerPage unless the last page has been requested
	// (determined by `totalCount - limit`).
	capacity := totalCount - limit
	if capacity >= RecordsPerPage {
		capacity = RecordsPerPage
	}
	paging := &app.BillSheetMediaPaging{
		Pager: &app.Pager{
			CurrentPage:    limit / RecordsPerPage,
			RecordsPerPage: RecordsPerPage,
			TotalCount:     totalCount,
			TotalPages:     int(math.Ceil(float64(totalCount) / float64(RecordsPerPage))),
		},
		Billsheets: make([]*app.BillSheetItem, capacity),
	}
	err = s.CollectRows(rows, paging.Billsheets)
	if err != nil {
		return nil, err
	}
	return paging, nil
}

func (s *BillSheet) Query(db *mysql.DB) (interface{}, error) {
	query := s.Data.(*app.BillSheetQueryPayload)
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", fmt.Sprintf("WHERE %s", *query.WhereClause)))
	if err != nil {
		return nil, err
	}
	var totalCount int
	for rows.Next() {
		err = rows.Scan(&totalCount)
		if err != nil {
			return nil, err
		}
	}
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "*", fmt.Sprintf("WHERE %s LIMIT %d,%d", *query.WhereClause, 0, RecordsPerPage)))
	if err != nil {
		return nil, err
	}
	capacity := RecordsPerPage
	if totalCount < RecordsPerPage {
		capacity = totalCount
	}
	paging := &app.BillSheetMediaPaging{
		Pager: &app.Pager{
			CurrentPage:    0,
			RecordsPerPage: RecordsPerPage,
			TotalCount:     totalCount,
			TotalPages:     int(math.Ceil(float64(totalCount) / float64(RecordsPerPage))),
		},
		Billsheets: make([]*app.BillSheetItem, capacity),
	}
	err = s.CollectRows(rows, paging.Billsheets)
	if err != nil {
		return nil, err
	}
	return paging, nil
}

func (s *BillSheet) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.BillSheetPayload)
	hold := payload.Hold
	// First, check if there is a previous hold placed by another IC.
	count, _ := s.CheckForHold(db, payload)
	if count > 2 {
		// We shouldn't ever get here!!
		return nil, fmt.Errorf("Consumer has multiple entries on %s with code %d, aborting.  Please see Leta.", payload.ServiceDate, payload.ServiceCode)
	} else if count == 2 {
		// If there is a match that means that there are already two matching entries for the hold criteria, so under no circumstances
		// should hold be checked as `true` for this particular entry!
		hold = false
	}
	// For now, don't update the billsheet table if the update on consumer fails!
	err := updateConsumerUnits(payload.Consumer, *payload.Units, db)
	if err != nil {
		return nil, err
	}
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}
	_, err = stmt.Exec(payload.Specialist, payload.Consumer, payload.Hours, payload.Units, payload.ServiceDate, payload.ServiceCode, hold, payload.ContractType, payload.RecipientID, payload.RecordNumber, payload.Status, payload.BilledCode, payload.BilledAmount, payload.County, payload.Confirmation, payload.Description, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.BillSheetMedia{
		ID:           *payload.ID,
		Specialist:   payload.Specialist,
		Consumer:     payload.Consumer,
		Hours:        payload.Hours,
		Units:        payload.Units,
		ServiceDate:  payload.ServiceDate,
		ServiceCode:  payload.ServiceCode,
		Hold:         payload.Hold,
		ContractType: payload.ContractType,
		RecipientID:  payload.RecipientID,
		RecordNumber: payload.RecordNumber,
		Status:       payload.Status,
		BilledCode:   payload.BilledCode,
		BilledAmount: payload.BilledAmount,
		County:       payload.County,
		Confirmation: payload.Confirmation,
		Description:  payload.Description,
	}, nil
}
