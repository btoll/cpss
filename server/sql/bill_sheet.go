package sql

import (
	mysql "database/sql"
	"errors"
	"fmt"
	"math"
	"strconv"
	"strings"
	"time"

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
			"CONSUMER_INNER_JOIN": "INNER JOIN consumer ON consumer.id = billsheet.consumer INNER JOIN active ON consumer.active = active.id",
			"DELETE":              "DELETE FROM billsheet WHERE id=?",
			"GET_AUTH_LEVEL":      "SELECT authLevel FROM specialist WHERE id=%d",
			"GET_UNIT_RATE":       "SELECT unitRate FROM service_code WHERE id=%d",
			"INSERT":              "INSERT billsheet SET specialist=?,consumer=?,units=?,serviceDate=?,serviceCode=?,hold=?,contractType=?,recipientID=?,status=?,billedCode=?,billedAmount=?,county=?,confirmation=?,description=?",
			"SELECT":              "SELECT %s FROM billsheet %s",
			"SELECT_UNIT_BLOCK":   "SELECT %s FROM unit_block WHERE consumer=%d AND serviceCode=%d",
			"UPDATE_UNIT_BLOCK":   "UPDATE unit_block SET units=? WHERE id=?",
			"UPDATE":              "UPDATE billsheet SET specialist=?,consumer=?,units=?,serviceDate=?,serviceCode=?,hold=?,contractType=?,recipientID=?,status=?,billedCode=?,billedAmount=?,county=?,confirmation=?,description=? WHERE id=?",
		},
	}
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
		var units float64
		var serviceDate string
		var serviceCode int
		var hold bool
		var contractType string
		var recipientID string
		var status int
		var billedCode string
		var billedAmount float64
		var county int
		var confirmation string
		var description string
		err := rows.Scan(&id, &specialist, &consumer, &units, &serviceDate, &serviceCode, &hold, &contractType, &recipientID, &status, &billedCode, &billedAmount, &county, &confirmation, &description)
		if err != nil {
			return err
		}
		coll[i] = &app.BillSheetItem{
			ID:           id,
			Specialist:   specialist,
			Consumer:     consumer,
			Units:        &units,
			ServiceDate:  serviceDate,
			ServiceCode:  serviceCode,
			Hold:         hold,
			ContractType: &contractType,
			RecipientID:  &recipientID,
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
	if _, err := s.IsLegalDate(db, payload); err != nil {
		return nil, err
	}
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
	// For now, don't update the billsheet table if the unit rate lookup fails!
	unitRate, err := s.GetUnitRate(db, payload.ServiceCode)
	if err != nil {
		return nil, err
	}
	// For now, don't update the billsheet table if the update on consumer fails!
	// 4 units per hour!
	err = s.UpdateUnitBlock(db, payload, 0)
	if err != nil {
		return nil, err
	}
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Specialist, payload.Consumer, payload.Units, payload.ServiceDate, payload.ServiceCode, payload.Hold, payload.ContractType, payload.RecipientID, payload.Status, payload.BilledCode, unitRate*(*payload.Units), payload.County, payload.Confirmation, payload.Description)
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

func (s *BillSheet) GetAuthLevel(db *mysql.DB, specialist int) (int, error) {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["GET_AUTH_LEVEL"], specialist))
	if err != nil {
		return -1, err
	}
	var id int
	for rows.Next() {
		err = rows.Scan(&id)
		if err != nil {
			return -1, err
		}
	}
	return id, nil
}

func (s *BillSheet) GetUnitRate(db *mysql.DB, serviceCode int) (float64, error) {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["GET_UNIT_RATE"], serviceCode))
	if err != nil {
		return -1, err
	}
	var unitRate float64
	for rows.Next() {
		err = rows.Scan(&unitRate)
		if err != nil {
			return -1, err
		}
	}
	return unitRate, nil
}

func (s *BillSheet) IsLegalDate(db *mysql.DB, payload *app.BillSheetPayload) (bool, error) {
	// If admin, always pass as legal!
	if id, err := s.GetAuthLevel(db, payload.Specialist); err != nil {
		return false, err
	} else if id == 1 {
		return true, nil
	}
	parts := strings.Split(payload.ServiceDate, "-")
	year, err := strconv.Atoi(parts[0])
	if err != nil {
		return false, errors.New("Bad date: year is incorrect")
	}
	month, err := strconv.Atoi(parts[1])
	if err != nil {
		return false, errors.New("Bad date: month is incorrect")
	}
	day, err := strconv.Atoi(parts[2])
	if err != nil {
		return false, errors.New("Bad date: day is incorrect")
	}
	userEntered := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.UTC)
	tyear, tmonth, tday := time.Now().Date()
	today := time.Date(tyear, tmonth, tday, 0, 0, 0, 0, time.UTC)
	// https://golang.org/pkg/time/#Time.Sub
	// When the day before is selected, will appear as `-24h0m0s`.  -- Illegal!
	// For the same day, will appear as `0s`.                       -- Legal!
	// When the day after is selected, will appear as `-24h0m0s`.   -- Legal!
	if userEntered.Sub(today) < 0 {
		return false, errors.New("Bad date: Service Date cannot be in the past")
	}
	return true, nil
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
	//
	//select billsheet.* from billsheet inner join consumer on consumer.id = billsheet.consumer inner join active on consumer.active = active.id where active.id = 1 and billsheet.specialist = 2;
	//
	query := s.Data.(*PageQuery)
	limit := query.Page * RecordsPerPage
	whereClause := ""
	if query.WhereClause != "" {
		whereClause = fmt.Sprintf(" AND %s", query.WhereClause)
	}
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", fmt.Sprintf("%s WHERE active.id = 1 %s", s.Stmt["CONSUMER_INNER_JOIN"], whereClause)))
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "billsheet.*", fmt.Sprintf("%s WHERE active.id = 1 %s ORDER BY billsheet.serviceDate DESC LIMIT %d,%d", s.Stmt["CONSUMER_INNER_JOIN"], whereClause, limit, RecordsPerPage)))
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

func (s *BillSheet) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.BillSheetPayload)
	if _, err := s.IsLegalDate(db, payload); err != nil {
		return nil, err
	}
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
	// For now, don't update the billsheet table if the unit rate lookup fails!
	unitRate, err := s.GetUnitRate(db, payload.ServiceCode)
	if err != nil {
		return nil, err
	}
	// We need to know the current number of units for this record so we can adjust the unit block accordingly!
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "units", fmt.Sprintf("WHERE id=%d", *payload.ID)))
	var units float64
	for rows.Next() {
		err = rows.Scan(&units)
		if err != nil {
			return nil, err
		}
	}
	// For now, don't update the billsheet table if the update on unit_block fails!
	err = s.UpdateUnitBlock(db, payload, units)
	if err != nil {
		return nil, err
	}
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}
	_, err = stmt.Exec(payload.Specialist, payload.Consumer, payload.Units, payload.ServiceDate, payload.ServiceCode, hold, payload.ContractType, payload.RecipientID, payload.Status, payload.BilledCode, unitRate*(*payload.Units), payload.County, payload.Confirmation, payload.Description, payload.ID)
	if err != nil {
		return nil, err
	}
	return &app.BillSheetMedia{
		ID:           *payload.ID,
		Specialist:   payload.Specialist,
		Consumer:     payload.Consumer,
		Units:        payload.Units,
		ServiceDate:  payload.ServiceDate,
		ServiceCode:  payload.ServiceCode,
		Hold:         payload.Hold,
		ContractType: payload.ContractType,
		RecipientID:  payload.RecipientID,
		Status:       payload.Status,
		BilledCode:   payload.BilledCode,
		BilledAmount: payload.BilledAmount,
		County:       payload.County,
		Confirmation: payload.Confirmation,
		Description:  payload.Description,
	}, nil
}

func (s *BillSheet) UpdateUnitBlock(db *mysql.DB, payload *app.BillSheetPayload, currentRecordUnits float64) error {
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT_UNIT_BLOCK"], "COUNT(*)", payload.Consumer, payload.ServiceCode))
	if err != nil {
		return err
	}
	var count int
	for rows.Next() {
		err = rows.Scan(&count)
		if err != nil {
			return err
		}
	}
	if count == 0 {
		return errors.New("This Consumer is not authorized for that Service Code!")
	} else if count < 1 {
		return errors.New("This Consumer has multiple entries for this Service Code, please see Leta!")
	} else if count == 1 {
		rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT_UNIT_BLOCK"], "id, units", payload.Consumer, payload.ServiceCode))
		if err != nil {
			return err
		}
		var id int
		var currentBlockUnits float64
		for rows.Next() {
			err := rows.Scan(&id, &currentBlockUnits)
			if err != nil {
				return err
			}
		}
		stmt, err := db.Prepare(s.Stmt["UPDATE_UNIT_BLOCK"])
		if err != nil {
			return err
		}
		// New hours - current hours * 4 units per hour.
		//		newUnits := currentUnits - (currentHours * 4.0)
		newUnits := currentBlockUnits + (currentRecordUnits - *payload.Units)
		// TODO: What happens if it's drawn down below zero?
		if newUnits < 0 {
			newUnits = 0
		}
		_, err = stmt.Exec(newUnits, id)
		if err != nil {
			return err
		}
	}
	return nil
}
