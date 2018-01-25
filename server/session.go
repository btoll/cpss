package main

import (
	"github.com/btoll/cpss/server/app"
	"github.com/btoll/cpss/server/sql"
	"github.com/goadesign/goa"
)

// SessionController implements the Session resource.
type SessionController struct {
	*goa.Controller
}

// NewSessionController creates a Session controller.
func NewSessionController(service *goa.Service) *SessionController {
	return &SessionController{Controller: service.NewController("SessionController")}
}

func (c *SessionController) Auth(ctx *app.AuthSessionContext) error {
	// SessionController_Auth: start_implement

	rec, err := sql.VerifyPassword(ctx.Payload.Username, ctx.Payload.Password)
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.SessionMedia))

	// SessionController_Auth: end_implement
}

func (c *SessionController) Hash(ctx *app.HashSessionContext) error {
	// SessionController_Hash: start_implement

	return ctx.OK(&app.SessionMedia{
		ID:        *ctx.Payload.ID,
		Username:  ctx.Payload.Username,
		Password:  sql.Hash(ctx.Payload.Password),
		Firstname: *ctx.Payload.Firstname,
		Lastname:  *ctx.Payload.Lastname,
		Email:     *ctx.Payload.Email,
		Payrate:   *ctx.Payload.Payrate,
		AuthLevel: *ctx.Payload.AuthLevel,
	})

	// SessionController_Verify: end_implement
}
