/**
 * @ingroup enums
 * Type of the sent report.
 */
typedef NS_ENUM(NSString, AssetsDeploymentStatus) {
    /**
     * {@link AssetsDownloadStatusReport}.
     */
    DOWNLOAD = "Error occurred during delivering download status report.",
    
    /**
     * {@link AssetsDeploymentStatusReport}.
     */
    DEPLOY = "Error occurred during delivering deploy status report."
};
