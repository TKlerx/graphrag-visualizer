import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import GraphViewer from "./GraphViewer";
import {
  Box,
  Button,
  Card,
  CardContent,
  Container,
  Stack,
  Tab,
  Tabs,
  Typography,
} from "@mui/material";
import { useDropzone } from "react-dropzone";
import DropZone from "./DropZone";
import Introduction from "./Introduction";
import useFileHandler from "../hooks/useFileHandler";
import useGraphData from "../hooks/useGraphData";
import DataTableContainer from "./DataTableContainer";
import ReactGA from "react-ga4";

const demoArtifactSets = [
  {
    id: "forterro-only-v1",
    label: "Forterro Only",
    path: "artifact-sets/forterro-only-v1",
    apiGraphId: "forterro-only-v1",
    description: "Original public proxy corpus before adding proALPHA.",
    stats: "14 docs · 653 entities · 920 relationships · 155 communities",
  },
  {
    id: "proalpha-target-v2",
    label: "Forterro + proALPHA",
    path: "artifact-sets/proalpha-target-v2",
    apiGraphId: "proalpha-target-v2",
    description: "Expanded corpus with proALPHA as the hypothetical target.",
    stats: "21 docs · 707 entities · 998 relationships · 181 communities",
  },
];

const GraphDataHandler: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();

  const [tabIndex, setTabIndex] = useState(0);
  const [graphType, setGraphType] = useState<"2d" | "3d">("2d");
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [selectedTable, setSelectedTable] = useState<
    | "entities"
    | "relationships"
    | "documents"
    | "textunits"
    | "communities"
    | "communityReports"
    | "covariates"
  >("entities");
  const [includeDocuments, setIncludeDocuments] = useState(false);
  const [includeTextUnits, setIncludeTextUnits] = useState(false);
  const [includeCommunities, setIncludeCommunities] = useState(false);
  const [includeCovariates, setIncludeCovariates] = useState(false);
  const [maxEntities, setMaxEntities] = useState(500);
  const [activeArtifactSet, setActiveArtifactSet] = useState<string>("Current");
  const [activeApiGraphId, setActiveApiGraphId] = useState<string>("default");
  const [loadingArtifactSet, setLoadingArtifactSet] = useState<string | null>(
    null
  );

  const {
    entities,
    relationships,
    documents,
    textunits,
    communities,
    covariates,
    communityReports,
    handleFilesRead,
    loadDefaultFiles,
    loadArtifactSet,
  } = useFileHandler();

  const graphData = useGraphData(
    entities,
    relationships,
    documents,
    textunits,
    communities,
    communityReports,
    covariates,
    includeDocuments,
    includeTextUnits,
    includeCommunities,
    includeCovariates,
    maxEntities
  );

  const hasDocuments = documents.length > 0;
  const hasTextUnits = textunits.length > 0;
  const hasCommunities = communities.length > 0;
  const hasCovariates = covariates.length > 0;

  useEffect(() => {
    if (process.env.NODE_ENV === "development") {
      loadDefaultFiles();
    }
    // eslint-disable-next-line
  }, []);

  useEffect(() => {
    const measurementId = process.env.REACT_APP_GA_MEASUREMENT_ID;
    if (measurementId) {
      ReactGA.initialize(measurementId);
    } else {
      console.error("Google Analytics measurement ID not found");
    }
  }, []);

  useEffect(() => {
    // **Set tab index based on the current path**
    switch (location.pathname) {
      case "/upload":
        setTabIndex(0);
        break;
      case "/graph":
        setTabIndex(1);
        break;
      case "/data":
        setTabIndex(2);
        break;
      default:
        setTabIndex(0);
    }
  }, [location.pathname]);

  const onDrop = (acceptedFiles: File[]) => {
    handleFilesRead(acceptedFiles);
    setActiveArtifactSet("Uploaded files");
    setActiveApiGraphId("default");
    navigate("/graph", { replace: true });
  };

  const handleLoadArtifactSet = async (artifactSet: (typeof demoArtifactSets)[number]) => {
    setLoadingArtifactSet(artifactSet.id);
    try {
      await loadArtifactSet(artifactSet.path);
      setActiveArtifactSet(artifactSet.label);
      setActiveApiGraphId(artifactSet.apiGraphId);
      setMaxEntities(500);
    } finally {
      setLoadingArtifactSet(null);
    }
  };

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    noClick: false,
    noKeyboard: true,
    accept: {
      "application/x-parquet": [".parquet"],
    },
  });

  const handleChange = (event: React.ChangeEvent<{}>, newValue: number) => {
    setTabIndex(newValue);
    let path = "/upload";
    if (newValue === 1) path = "/graph";
    if (newValue === 2) path = "/data";
    navigate(path);
    ReactGA.send({
      hitType: "event",
      eventCategory: "Tabs",
      eventAction: "click",
      eventLabel: `Tab ${newValue}`,
    });
  };

  const toggleGraphType = () => {
    setGraphType((prevType) => (prevType === "2d" ? "3d" : "2d"));
  };

  const toggleFullscreen = () => {
    setIsFullscreen(!isFullscreen);
  };

  return (
    <>
      <Tabs value={tabIndex} onChange={handleChange} centered>
        <Tab label="Upload Artifacts" />
        <Tab label="Graph Visualization" />
        <Tab label="Data Tables" />
      </Tabs>
      {tabIndex === 0 && (
        <Container
          maxWidth="md"
          sx={{
            mt: 3,
            display: "flex",
            flexDirection: "column",
          }}
        >
          <DropZone {...{ getRootProps, getInputProps, isDragActive }} />
          <Box sx={{ mt: 3 }}>
            <Typography variant="h5" gutterBottom>
              Demo Graph Snapshots
            </Typography>
            <Stack spacing={2}>
              {demoArtifactSets.map((artifactSet) => (
                <Card key={artifactSet.id} variant="outlined">
                  <CardContent>
                    <Stack
                      direction={{ xs: "column", sm: "row" }}
                      spacing={2}
                      alignItems={{ xs: "stretch", sm: "center" }}
                      justifyContent="space-between"
                    >
                      <Box>
                        <Typography variant="h6">{artifactSet.label}</Typography>
                        <Typography variant="body2" color="text.secondary">
                          {artifactSet.description}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {artifactSet.stats}
                        </Typography>
                      </Box>
                      <Button
                        variant={
                          activeArtifactSet === artifactSet.label
                            ? "contained"
                            : "outlined"
                        }
                        onClick={() => handleLoadArtifactSet(artifactSet)}
                        disabled={loadingArtifactSet !== null}
                        sx={{ minWidth: 160 }}
                      >
                        {loadingArtifactSet === artifactSet.id
                          ? "Loading..."
                          : activeArtifactSet === artifactSet.label
                          ? "Loaded"
                          : "Load Graph"}
                      </Button>
                    </Stack>
                  </CardContent>
                </Card>
              ))}
            </Stack>
          </Box>
          <Introduction />
        </Container>
      )}
      {tabIndex === 1 && (
        <Box
          p={3}
          sx={{
            height: isFullscreen ? "100vh" : "calc(100vh - 64px)",
            width: isFullscreen ? "100vw" : "100%",
            position: isFullscreen ? "fixed" : "relative",
            top: 0,
            left: 0,
            zIndex: isFullscreen ? 1300 : "auto",
            overflow: "hidden",
          }}
        >
          <GraphViewer
            data={graphData}
            graphType={graphType}
            isFullscreen={isFullscreen}
            onToggleFullscreen={toggleFullscreen}
            onToggleGraphType={toggleGraphType}
            includeDocuments={includeDocuments}
            includeTextUnits={includeTextUnits}
            onIncludeDocumentsChange={() =>
              setIncludeDocuments(!includeDocuments)
            }
            onIncludeTextUnitsChange={() =>
              setIncludeTextUnits(!includeTextUnits)
            }
            includeCommunities={includeCommunities}
            onIncludeCommunitiesChange={() =>
              setIncludeCommunities(!includeCommunities)
            }
            includeCovariates={includeCovariates}
            onIncludeCovariatesChange={() =>
              setIncludeCovariates(!includeCovariates)
            }
            hasDocuments={hasDocuments}
            hasTextUnits={hasTextUnits}
            hasCommunities={hasCommunities}
            hasCovariates={hasCovariates}
            maxEntities={maxEntities}
            onMaxEntitiesChange={setMaxEntities}
            totalEntities={entities.length}
            apiGraphId={activeApiGraphId}
            selectedGraphLabel={activeArtifactSet}
          />
        </Box>
      )}

      {tabIndex === 2 && (
        <Box sx={{ display: "flex", height: "calc(100vh - 64px)" }}>
          <DataTableContainer
            selectedTable={selectedTable}
            setSelectedTable={setSelectedTable}
            entities={entities}
            relationships={relationships}
            documents={documents}
            textunits={textunits}
            communities={communities}
            communityReports={communityReports}
            covariates={covariates}
          />
        </Box>
      )}
    </>
  );
};

export default GraphDataHandler;
