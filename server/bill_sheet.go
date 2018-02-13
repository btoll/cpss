package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
)

// BillSheetController implements the BillSheet resource.
type BillSheetController struct {
	*goa.Controller
}

// NewBillSheetController creates a BillSheet controller.
func NewBillSheetController(service *goa.Service) *BillSheetController {
	return &BillSheetController{Controller: service.NewController("BillSheetController")}
}

// Create runs the create action.
func (c *BillSheetController) Create(ctx *app.CreateBillSheetContext) error {
	// BillSheetController_Create: start_implement

	id, err := sql.Create(sql.NewBillSheet(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.BillSheetMediaTiny{id.(int)})

	// BillSheetController_Create: end_implement
}

// Delete runs the delete action.
func (c *BillSheetController) Delete(ctx *app.DeleteBillSheetContext) error {
	// BillSheetController_Delete: start_implement

	err := sql.Delete(sql.NewBillSheet(ctx.ID))
	if err != nil {
		return err
	}
	return ctx.OKTiny(&app.BillSheetMediaTiny{ctx.ID})

	// BillSheetController_Delete: end_implement
}

// List runs the list action.
func (c *BillSheetController) List(ctx *app.ListBillSheetContext) error {
	// BillSheetController_List: start_implement

	collection, err := sql.List(sql.NewBillSheet(nil))
	if err != nil {
		return err
	}
	return ctx.OK(collection.(app.BillSheetMediaCollection))

	// BillSheetController_List: end_implement
}

// Update runs the update action.
func (c *BillSheetController) Update(ctx *app.UpdateBillSheetContext) error {
	// BillSheetController_Update: start_implement

	rec, err := sql.Update(sql.NewBillSheet(ctx.Payload))
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.BillSheetMedia))

	// BillSheetController_Update: end_implement
}
