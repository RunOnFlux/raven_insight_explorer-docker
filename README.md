# raven_insight_explorer-docker
Raven Insight Explorer


# RAVEN INSIGHT EXPLORER
<b> DOCKER IMAGE INCLUDES: </b>
- Raven Daemon
- Insight-API
- Insight-UI
- Ravencore-Node

<br>MongoDB installed separatly as independent component

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`BOOTSTRAP`| When set to ```1```, application will download and unpack bootstrap archive for flux daemon. | (unset) |
|`DB_COMPONENT_NAME`| Name of mongo host for insight-api. | `fluxmongodb_explorerflux` |
 - Name of mongo continer must be same as `DB_COMPONENT_NAME`
