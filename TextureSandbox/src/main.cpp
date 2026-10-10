#include <GLFW/glfw3.h>
#include <cstdint>
#include <print>

int main()
{
	if (!glfwInit())
	{
		std::println(stderr, "Error: Unable to initialize GLFW");
	}

	GLFWmonitor* primaryMonitor = glfwGetPrimaryMonitor();
	const GLFWvidmode* videoMode = glfwGetVideoMode(primaryMonitor);
	const int32_t width = static_cast<int32_t>(videoMode->width * 0.7);
	const int32_t height = static_cast<int32_t>(videoMode->height * 0.8);

	glfwWindowHint(GLFW_SCALE_TO_MONITOR, GLFW_FALSE);
	glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
	GLFWwindow* window = glfwCreateWindow(
		width,
		height,
		"TextureSandbox - D3D11",
		nullptr,
		nullptr
	);

	if (window == nullptr)
	{
		std::println(stderr, "Error: GLFW unable to create window");
		glfwTerminate();
		return -1;
	}

	const int32_t windowLeft = videoMode->width / 2 - width / 2;
	const int32_t windowTop = videoMode->height / 2 - height / 2;
	glfwSetWindowPos(window, windowLeft, windowTop);

	while (!glfwWindowShouldClose(window))
	{
		glfwPollEvents();
	}
	
	glfwDestroyWindow(window);
	glfwTerminate();

	return 0;
}