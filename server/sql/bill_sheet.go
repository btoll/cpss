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
			"INSERT":              "INSERT billsheet SET specialist=?,consumer=?,units=?,serviceDate=?,serviceCode=?,status=?,billedAmount=?,confirmation=?,description=?",
			"SELECT":              "SELECT %s FROM billsheet %s",
			"SELECT_UNIT_BLOCK":   "SELECT %s FROM unit_block WHERE consumer=%d AND serviceCode=%d",
			"UPDATE_UNIT_BLOCK":   "UPDATE unit_block SET units=? WHERE id=?",
			"UPDATE":              "UPDATE billsheet SET specialist=?,consumer=?,units=?,serviceDate=?,serviceCode=?,status=?,billedAmount=?,confirmation=?,description=? WHERE id=?",
		},
	}
}

func floatToString(f float64) string {
	// func FormatFloat(f float64, fmt byte, prec, bitSize int) string
	return strconv.FormatFloat(f, 'f', 2, 64)
}

func (s *BillSheet) CollectRows(rows *mysql.Rows, coll []*app.BillSheetItem) error {
	i := 0
	for rows.Next() {
		var id int
		var specialist int
		var consumer int
		var units string
		var serviceDate string
		var serviceCode int
		var status int
		var billedAmount float64
		var confirmation string
		var description string
		err := rows.Scan(&id, &specialist, &consumer, &units, &serviceDate, &serviceCode, &status, &billedAmount, &confirmation, &description)
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
			Status:       &status,
			BilledAmount: &billedAmount,
			Confirmation: &confirmation,
			Description:  &description,
		}
		i++
	}
	return nil
}

func (s *BillSheet) Create(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.BillSheetPayload)
	var formattedDate string
	isLegal, formattedDate, err := s.IsLegalDate(db, payload)
	if isLegal == false {
		return nil, err
	}
	if isDuplicate, err := s.IsDuplicateEntry(db, payload, formattedDate); isDuplicate == true {
		return nil, err
	}
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
		return nil, err
	}
	units, err := strconv.ParseFloat(*payload.Units, 64)
	if err != nil {
		return nil, err
	}
	f := unitRate * (units)
	// Round to the second decimal place.
	// https://yourbasic.org/golang/round-float-2-decimal-places/
	f = math.Ceil(f*100) / 100
	res, err := stmt.Exec(payload.Specialist, payload.Consumer, units, formattedDate, payload.ServiceCode, payload.Status, f, payload.Confirmation, payload.Description)
	if err != nil {
		return -1, err
	}
	var lastID int64
	lastID, err = res.LastInsertId()
	if err != nil {
		return -1, err
	}
	toStr := floatToString(units)
	return &app.BillSheetMedia{
		ID:           int(lastID),
		Specialist:   payload.Specialist,
		Consumer:     payload.Consumer,
		Units:        &toStr,
		ServiceDate:  payload.ServiceDate,
		ServiceCode:  payload.ServiceCode,
		Status:       payload.Status,
		BilledAmount: &f,
		Confirmation: payload.Confirmation,
		Description:  payload.Description,
	}, nil
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

func (s *BillSheet) IsDuplicateEntry(db *mysql.DB, payload *app.BillSheetPayload, formattedDate string) (bool, error) {
	// Check to see if this is a duplicate entry!
	rows, err := db.Query(fmt.Sprintf(s.Stmt["SELECT"], "COUNT(*)", fmt.Sprintf("WHERE specialist=%d AND consumer=%d AND serviceCode=%d AND serviceDate='%s'", payload.Specialist, payload.Consumer, payload.ServiceCode, formattedDate)))
	if err != nil {
		return true, err
	}
	var count int
	for rows.Next() {
		err = rows.Scan(&count)
		if err != nil {
			return true, err
		}
	}
	if count > 0 {
		return true, errors.New("Duplicate entry: This Specialist already has an entry for this Consumer and ServiceCode on this ServiceDate!")
	}
	return false, nil
}

func (s *BillSheet) IsLegalDate(db *mysql.DB, payload *app.BillSheetPayload) (bool, string, error) {
	var id int
	id, err := s.GetAuthLevel(db, *payload.RealSpecialist)
	if err != nil {
		return false, "", err
	}
	parts := strings.Split(payload.ServiceDate, "/")
	month, err := strconv.Atoi(parts[0])
	if err != nil {
		return false, "", errors.New("Bad date: month is incorrect")
	}
	day, err := strconv.Atoi(parts[1])
	if err != nil {
		return false, "", errors.New("Bad date: day is incorrect")
	}
	//
	// Note that since dates can't be backdated, it's safe to use the current year!
	//
	tyear, tmonth, tday := time.Now().Date()
	userEntered := time.Date(tyear, time.Month(month), day, 0, 0, 0, 0, time.UTC)
	today := time.Date(tyear, tmonth, tday, 0, 0, 0, 0, time.UTC)
	// https://golang.org/pkg/time/#Time.Sub
	// When the day before is selected, will appear as `-24h0m0s`.  -- Illegal!
	// For the same day, will appear as `0s`.                       -- Legal!
	// When the day after is selected, will appear as `-24h0m0s`.   -- Legal!
	//
	// Note that admins (id == 1) can back date!
	if userEntered.Sub(today) < 0 && id == 2 {
		return false, "", errors.New("Bad date: Service Date cannot be in the past")
	}
	var formattedDate strings.Builder
	fmt.Fprintf(&formattedDate, "20%s-%s-%s", parts[2], parts[0], parts[1])
	return true, formattedDate.String(), nil
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "id,specialist,consumer,units,DATE_FORMAT(serviceDate, '%m/%d/%y') AS serviceDate,serviceCode,status,billedAmount,confirmation,description", ""))
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
	rows, err = db.Query(fmt.Sprintf(s.Stmt["SELECT"], "billsheet.id,billsheet.specialist,billsheet.consumer,billsheet.units,DATE_FORMAT(billsheet.serviceDate, '%m/%d/%y') AS serviceDate,billsheet.serviceCode,billsheet.status,billsheet.billedAmount,billsheet.confirmation,billsheet.description", fmt.Sprintf("%s WHERE active.id = 1 %s ORDER BY billsheet.serviceDate DESC LIMIT %d,%d", s.Stmt["CONSUMER_INNER_JOIN"], whereClause, limit, RecordsPerPage)))
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
	var formattedDate string
	isLegal, formattedDate, err := s.IsLegalDate(db, payload)
	if isLegal == false {
		return nil, err
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
	unitsFromString, err := strconv.ParseFloat(*payload.Units, 64)
	if err != nil {
		return nil, err
	}
	f := unitRate * (unitsFromString)
	// Round to the second decimal place.
	// https://yourbasic.org/golang/round-float-2-decimal-places/
	f = math.Ceil(f*100) / 100
	_, err = stmt.Exec(payload.Specialist, payload.Consumer, unitsFromString, formattedDate, payload.ServiceCode, payload.Status, f, payload.Confirmation, payload.Description, payload.ID)
	if err != nil {
		return nil, err
	}
	toStr := floatToString(unitsFromString)
	return &app.BillSheetMedia{
		ID:           *payload.ID,
		Specialist:   payload.Specialist,
		Consumer:     payload.Consumer,
		Units:        &toStr,
		ServiceDate:  payload.ServiceDate,
		ServiceCode:  payload.ServiceCode,
		Status:       payload.Status,
		BilledAmount: &f,
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
		units, err := strconv.ParseFloat(*payload.Units, 64)
		if err != nil {
			return err
		}
		newUnits := currentBlockUnits + (currentRecordUnits - units)
		// TODO: What happens if it's drawn down below zero? For now, we're just entering it as-is with no reporting.
		_, err = stmt.Exec(newUnits, id)
		if err != nil {
			return err
		}
	}
	return nil
}
