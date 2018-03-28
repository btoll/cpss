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
			"INSERT": "INSERT billsheet SET specialist=?,consumer=?,hours=?,units=?,serviceDate=?,serviceCode=?,contractType=?,recipientID=?,recordNumber=?,status=?,billedCode=?,billedAmount=?,county=?,confirmation=?,description=?",
			"SELECT": "SELECT %s FROM billsheet %s",
			"UPDATE": "UPDATE billsheet SET specialist=?,consumer=?,hours=?,units=?,serviceDate=?,serviceCode=?,contractType=?,recipientID=?,recordNumber=?,status=?,billedCode=?,billedAmount=?,county=?,confirmation=?,description=? WHERE id=?",
		},
	}
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
		var contractType string
		var recipientID string
		var recordNumber string
		var status int
		var billedCode string
		var billedAmount float64
		var county int
		var confirmation string
		var description string
		err := rows.Scan(&id, &specialist, &consumer, &hours, &units, &serviceDate, &serviceCode, &contractType, &recipientID, &recordNumber, &status, &billedCode, &billedAmount, &county, &confirmation, &description)
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
	stmt, err := db.Prepare(s.Stmt["INSERT"])
	if err != nil {
		return -1, err
	}
	res, err := stmt.Exec(payload.Specialist, payload.Consumer, payload.Hours, payload.Units, payload.ServiceDate, payload.ServiceCode, payload.ContractType, payload.RecipientID, payload.RecordNumber, payload.Status, payload.BilledCode, payload.BilledAmount, payload.County, payload.Confirmation, payload.Description)
	if err != nil {
		return -1, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return -1, err
	}
	return int(id), nil
}

func (s *BillSheet) Update(db *mysql.DB) (interface{}, error) {
	payload := s.Data.(*app.BillSheetPayload)
	stmt, err := db.Prepare(s.Stmt["UPDATE"])
	if err != nil {
		return nil, err
	}
	_, err = stmt.Exec(payload.Specialist, payload.Consumer, payload.Hours, payload.Units, payload.ServiceDate, payload.ServiceCode, payload.ContractType, payload.RecipientID, payload.RecordNumber, payload.Status, payload.BilledCode, payload.BilledAmount, payload.County, payload.Confirmation, payload.Description, payload.ID)
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
