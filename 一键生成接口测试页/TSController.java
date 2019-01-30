package com.xw.project.controller.comm;

import com.xw.core.util.StringUtil;
import com.xw.project.entity.PersonInfo;
import org.springframework.core.DefaultParameterNameDiscoverer;
import org.springframework.core.LocalVariableTableParameterNameDiscoverer;
import org.springframework.core.MethodParameter;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
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
	private static final String packageName = "com.xw.project.controller";
	private static LocalVariableTableParameterNameDiscoverer parameterNameDiscoverer = new LocalVariableTableParameterNameDiscoverer();
	private static String ROOT_PATH;
	private static List<Class> classList;

	private static List<ControlVo> controlVoList;
	private static List<packageVo> packageVoList;

	private static Map<String, List<MethodVO>> controlMap;

	static {
		URL url = TSController.class.getResource("/");
		ROOT_PATH = url.getPath();
		File controller = new File(ROOT_PATH, packageName.replaceAll("\\.", "/"));
		classList = new ArrayList<>();
		loadClass(controller);
		resolveMethod();
	}

	public static void main(String[] args) {
		System.out.println(1);
	}

	@RequestMapping("/getUrl")
	@ResponseBody
	public Object getUrl() {
		return packageVoList;
	}

	@RequestMapping("/file")
	@ResponseBody
	public Object test(@RequestParam("fileList") MultipartFile[] files,String name) {

		return files.length;
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
			controlVo = new ControlVo();
			controlVo.setPackageName(c.getPackage().getName());
			controlVo.setUrl(c.getSimpleName());
			controlVo.setMethodVOS(methodVOList);
			controlVoList.add(controlVo);
		}


		packageVoList = new ArrayList<>();
		Set<String> s = new HashSet<>();
		for (ControlVo cVO : controlVoList) {
			s.add(cVO.getPackageName());
		}
		packageVo packageVo;
		List<ControlVo> tempControlVoList;
		for (String s1 : s) {
			packageVo = new packageVo();
			tempControlVoList = new ArrayList<>();
			packageVo.setPackageName(s1);
			for (ControlVo c : controlVoList) {
				if (c.getPackageName().equals(s1)) {
					tempControlVoList.add(c);
				}
			}
			packageVo.setControlVoList(tempControlVoList);
			packageVoList.add(packageVo);
		}

	}

	private static List<ParameterVO> getMethodParameters(Method method) {
		String[] parameterNames = parameterNameDiscoverer.getParameterNames(method);
		MethodParameter methodParameter;

		List<ParameterVO> parameterVOList = new ArrayList<>();
		ParameterVO parameterVO;
		Class<?> parameterType;

		Parameter[] parameters = method.getParameters();

		for (int i = 0; i < parameters.length; i++) {
			methodParameter = new MethodParameter(method, i);
			parameterVO = new ParameterVO();
			parameterVO.setName(parameterNames[i]);
			parameterType = methodParameter.getParameterType();
			parameterVO.setTypeName(parameterType.getSimpleName());
			if (parameterType == MultipartFile.class || parameterType == MultipartFile[].class) {
				parameterVO.setFile(true);
				RequestParam requestParam = parameters[i].getAnnotation(RequestParam.class);
				if (requestParam != null) {
					if (StringUtil.isNotEmpty(requestParam.value())) {
						parameterVO.setName(requestParam.value());
					}
				}
			}
			parameterVOList.add(parameterVO);
		}
		for (Class<?> pType : method.getParameterTypes()) {
			if (isNotSimpleType(pType)) {
				for (Field field : pType.getDeclaredFields()) {
					String fieldName = field.getName();
					parameterVO = new ParameterVO();
					parameterVO.setName(fieldName);
					parameterVO.setTypeName(field.getType().getSimpleName());
					parameterVOList.add(parameterVO);
				}
			}
		}
		return parameterVOList;
	}

	public static class ParameterVO{
		private String name;
		private String typeName;
		private Boolean file;

		public String getName() {
			return name;
		}

		public void setName(String name) {
			this.name = name;
		}

		public String getTypeName() {
			return typeName;
		}

		public void setTypeName(String typeName) {
			this.typeName = typeName;
		}

		public Boolean getFile() {
			return file;
		}

		public void setFile(Boolean file) {
			this.file = file;
		}
	}

	public static class MethodVO {
		private String url;
		private List<ParameterVO> parameters;

		public String getUrl() {
			return url;
		}

		public void setUrl(String url) {
			this.url = url;
		}

		public List<ParameterVO> getParameters() {
			return parameters;
		}

		public void setParameters(List<ParameterVO> parameters) {
			this.parameters = parameters;
		}
	}

	public static class ControlVo{
		private String packageName;
		private String url;
		private List<MethodVO> methodVOS;

		public String getPackageName() {
			return packageName;
		}

		public void setPackageName(String packageName) {
			this.packageName = packageName;
		}

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

	public static class packageVo{
		private String packageName;
		private List<ControlVo> controlVoList;

		public String getPackageName() {
			return packageName;
		}

		public void setPackageName(String packageName) {
			this.packageName = packageName;
		}

		public List<ControlVo> getControlVoList() {
			return controlVoList;
		}

		public void setControlVoList(List<ControlVo> controlVoList) {
			this.controlVoList = controlVoList;
		}
	}

	private static Boolean isNotSimpleType(Class c){
		return c != Integer.class && c != int.class
				&& c != Float.class && c != float.class
				&& c!=Double.class && c!= double.class
				&& c!=Boolean.class && c!= boolean.class
				&& c!= String.class;
	}

}
