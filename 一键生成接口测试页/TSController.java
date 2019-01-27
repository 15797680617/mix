package com.xw.project.controller.comm;

import org.springframework.core.LocalVariableTableParameterNameDiscoverer;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.*;

/**
 * @author panchanghe
 * @Auther: pch
 * @Date: 2019-01-27 10:10
 * @Description:
 */
@Controller
@RequestMapping("/ts")
public class TSController {
	private static LocalVariableTableParameterNameDiscoverer parameterNameDiscoverer = new LocalVariableTableParameterNameDiscoverer();
	private static String ROOT_PATH;
	private static List<Class> classList;

	private static List<ControlVo> controlVoList;

	private static Map<String, List<MethodVO>> controlMap;

	static {
		String packageName = "com.xw.project.controller";
		URL url = TSController.class.getResource("/");
		ROOT_PATH = url.getPath();
		File controller = new File(ROOT_PATH, packageName.replaceAll("\\.", "/"));
		classList = new ArrayList<>();
		loadClass(controller);
		resolveMethod();
	}

	@RequestMapping("/getUrl")
	@ResponseBody
	public Object getUrl() {
		return controlVoList;
	}

	private static void loadClass(File file) {
		if (file.isFile()) {
			String clsName = file.getAbsolutePath().replace(ROOT_PATH, "");
			String cname = clsName.replaceAll("/", ".").replaceAll(".class", "");
			Class c;
			try {
				c = Class.forName(cname);
			} catch (ClassNotFoundException e) {
				return;
			}
			boolean flag = (c.getAnnotation(Controller.class) != null || c.getAnnotation(RestController.class) != null) && c.getAnnotation(RequestMapping.class) != null;
			if (flag) {
				classList.add(c);
			}
		} else {
			for (File f : file.listFiles()) {
				loadClass(f);
			}
		}
	}

	private static void resolveMethod() {
		controlVoList = new ArrayList<>(16);
		Method[] methods;
		RequestMapping requestMapping;
		String baseUrl;
		MethodVO vo;
		controlMap = new LinkedHashMap<>();
		List<MethodVO> methodVOList;
		ControlVo controlVo;
		for (Class c : classList) {
			try {
				baseUrl = ((RequestMapping) c.getAnnotation(RequestMapping.class)).value()[0];
			} catch (Exception e) {
				continue;
			}
			methods = c.getDeclaredMethods();
			methodVOList = new ArrayList<>();
			for (Method method : methods) {
				requestMapping = method.getAnnotation(RequestMapping.class);
				if (requestMapping != null) {
					vo = new MethodVO();
					vo.setUrl(baseUrl + requestMapping.value()[0]);
					vo.setParameters(getMethodParameters(method));
					methodVOList.add(vo);
				}
			}
			controlMap.put(baseUrl, methodVOList);
			controlVo = new ControlVo();
			controlVo.setUrl(c.getSimpleName());
			controlVo.setMethodVOS(methodVOList);
			controlVoList.add(controlVo);
		}
	}

	private static List<String> getMethodParameters(Method method) {
		String[] methodParameterNames = parameterNameDiscoverer.getParameterNames(method);
		if (methodParameterNames != null && methodParameterNames.length > 0) {
			return Arrays.asList(methodParameterNames);
		}
		return new ArrayList<>();
	}

	public static class MethodVO {
		private String url;
		private List<String> parameters;

		public String getUrl() {
			return url;
		}

		public void setUrl(String url) {
			this.url = url;
		}

		public List<String> getParameters() {
			return parameters;
		}

		public void setParameters(List<String> parameters) {
			this.parameters = parameters;
		}
	}

	public static class ControlVo{
		private String url;
		private List<MethodVO> methodVOS;

		public String getUrl() {
			return url;
		}

		public void setUrl(String url) {
			this.url = url;
		}

		public List<MethodVO> getMethodVOS() {
			return methodVOS;
		}

		public void setMethodVOS(List<MethodVO> methodVOS) {
			this.methodVOS = methodVOS;
		}
	}

}
