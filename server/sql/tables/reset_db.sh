#cat db.sql ../migration/full_dump.sql | mysql -u btoll -p

# Order matters!
#cat db.sql \
cat active.sql \
    authLevel.sql \
    dia.sql \
    fundingSource.sql \
    serviceCode.sql \
    status.sql \
    specialist.sql \
    county.sql \
    consumer.sql \
    billsheet.sql \
    payHistory.sql \
    unitBlock.sql \
    | mysql -u btoll -p

