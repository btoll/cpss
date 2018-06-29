# Order matters!
cat db.sql \
    active.sql \
    authLevel.sql \
    dia.sql \
    fundingSource.sql \
    serviceCode.sql \
    status.sql \
    specialist.sql \
    county.sql \
    city.sql \
    consumer.sql \
    billsheet.sql \
    payHistory.sql \
    unitBlock.sql \
    | mysql -u btoll -p

