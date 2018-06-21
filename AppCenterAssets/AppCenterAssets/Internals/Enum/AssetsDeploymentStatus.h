/**
 * Indicates the status of a deployment (after installing and restarting).
 */
typedef NS_ENUM(NSUInteger, MSAssetsDeploymentStatus) {
    /**
     * The deployment succeeded.
     */
    MSAssetsDeploymentStatusSucceeded,
    
    /**
     * The deployment failed (and was rolled back).
     */
    MSAssetsDeploymentStatusFailed
};
