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

// Auth runs the auth action.
func (c *SessionController) Auth(ctx *app.AuthSessionContext) error {
	// SessionController_Auth: start_implement

	rec, err := sql.VerifyPassword(*ctx.Payload.Username, ctx.Payload.Password)
	if err != nil {
		return err
	}
	return ctx.OK(rec.(*app.SessionMedia))

	// SessionController_Auth: end_implement
}

// Hash runs the hash action.
func (c *SessionController) Hash(ctx *app.HashSessionContext) error {
	// SessionController_Hash: start_implement

	return ctx.OKTiny(&app.SessionMediaTiny{
		ID:       *ctx.Payload.ID,
		Password: sql.Hash(ctx.Payload.Password),
	})

	// SessionController_Hash: end_implement
}
