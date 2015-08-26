module Glib.Scene.Camera;

import Glib.Scene.Transform;
import Glib.Scene.GObject;
import gl3n.linalg;

class Camera : GObject
{
	float near = .1;
	float far = 1000000;
	float fov = 45;
	float threshold = 1;
	float aspectRation = 1.25;
	
	vec3 right;
	vec3 direction;
	vec3 position = vec3(0,0,5);

	// Initial horizontal angle - toward -Z
    float horizontalAngle = 3.14f;

    // Initial vertical angle - none
    float verticalAngle = 0.0f;

    // Initial Field of View
    float initialFoV = 45.0f;

    float speed      = 3.0f; // 3 units / second
    float mouseSpeed = 0.0003f;
	
	this()
	{
		// Direction - Spherical coordinates to Cartesian coordinates conversion
        this.direction = vec3(
							  cos(this.verticalAngle) * sin(this.horizontalAngle),
							  sin(this.verticalAngle),
							  cos(this.verticalAngle) * cos(this.horizontalAngle)
							  );

        // Right vector
        this.right = vec3(
						  sin(this.horizontalAngle - 3.14f / 2.0f), // X
						  0,                                        // Y
						  cos(this.horizontalAngle - 3.14f / 2.0f)  // Z
						  );
	}
	mat4 getViewMatrix()
    {
        // Up vector
        vec3 up = cross(this.right, this.direction);

        return mat4.look_at(
							position,              // Camera is here
							position + direction,  // and looks here
							up                     //
							);
    }

	mat4 getPerspeciveMatrix()
	{
		float near = 0.1f;
		float far = 100.0f;
		return mat4.perspective(720.0, 440.0, fov, near, far);
	}
	void updateCameraControls(double xpos, double ypos)
	{
		xpos = xpos - 720/2;
		ypos = ypos - 440/2;
		xpos = max(-20, xpos).min(20);
        ypos = max(-20, ypos).min(20);

        // Compute the new orientation
        this.horizontalAngle -= this.mouseSpeed * cast(float)xpos;
        this.verticalAngle   -= this.mouseSpeed * cast(float)ypos;

        // Direction - Spherical coordinates to Cartesian coordinates conversion
        this.direction = vec3(
							  cos(this.verticalAngle) * sin(this.horizontalAngle),
							  sin(this.verticalAngle),
							  cos(this.verticalAngle) * cos(this.horizontalAngle)
							  );

        // Right vector
        this.right = vec3(
						  sin(this.horizontalAngle - 3.14f / 2.0f), // X
						  0,                                        // Y
						  cos(this.horizontalAngle - 3.14f / 2.0f)  // Z
						  );
	}
	/*
	this(Transform parent)
	{
		super(parent);
	}
	*/
}