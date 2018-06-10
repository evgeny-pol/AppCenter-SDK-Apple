/**
 * @ingroup enums
 * Indicates the status of a deployment (after installing and restarting).
 */
typedef NS_ENUM(NSString, AssetsDeploymentStatus) {
    /**
     * The deployment succeeded.
     */
    SUCCEEDED = "DeploymentSucceeded",
    
    /**
     * The deployment failed (and was rolled back).
     */
    FAILED = "DeploymentFailed"
};
