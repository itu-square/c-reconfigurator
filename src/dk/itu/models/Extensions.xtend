package dk.itu.models

import com.google.common.collect.AbstractIterator
import com.google.common.collect.FluentIterable
import com.google.common.collect.UnmodifiableIterator
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.PrintWriter
import java.util.Iterator
import java.util.List
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.eclipse.xtext.xbase.lib.Functions.Function2
import xtc.tree.Node
import xtc.util.Pair

import static dk.itu.models.Extensions.*
import java.util.function.Predicate
import java.util.function.Function

class Extensions {
	public static def String folder(String filePath) {
		filePath.substring(0, filePath.lastIndexOf(File.separator) + 1)
	}
	
	public static def String relativeTo(String path, String base) {
		if (path.startsWith(base)) { '''«path.substring(base.length)»''' }
		else path
	}
	
	public static def void writeToFile(String text, String file) {
		try {
			var PrintWriter file_output = new PrintWriter(new FileOutputStream(file));
			file_output.write(text);
			file_output.flush();
			file_output.close();
		} catch (IOException e) {
			System.err.println("Can not recover from the input or output fault");
		}
	}
	
	public static def void print(Object o) {
		System.out.print(o)
		Settings::systemOutPS.flush
	}
	
	public static def void println(Object o) {
		print(o + "\n")
	}
	
	public static def void println() {
		print("\n")
	}
	
	public static def printCode(Object o) {
		PrintCode::printCode(o)
	}
	
	public static def printAST(Object o) {
		PrintAST::printAST(o)
	}
	
	
	public static def Pair<Object> toPair(List<?> node) {
		node.toPair
	}

	public static def Pair<Object> toPair(Iterable<?> node) {
		var Pair<Object> p = Pair.empty()
		for (var i = node.size - 1; i >= 0; i--) {
			p = new Pair(node.get(i), p)
		}
		p
	}
	
	
	
	private static def <T> UnmodifiableIterator<T> filterIndexedHelper(Iterable<T> unfiltered, Function2<? super T, Integer, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		if (predicate == null) throw new NullPointerException();
		return new AbstractIterator<T>() {
			val iterator = unfiltered.iterator
			private var index = 0
			override protected T computeNext() {
				while (iterator.hasNext()) {
					val T element = iterator.next();
					if (predicate.apply(element, index++)) {
						return element;
					}
				}
				return endOfData();
			}
		};
  	}
	
	public static def <T> Iterable<T> filterIndexed (Iterable<T> unfiltered, Function2<? super T, Integer, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		println ("start")
		return new FluentIterable<T>() {
			override public Iterator<T> iterator() {
				return filterIndexedHelper(unfiltered, predicate);
			}
		}
	}
	
	
	
	private static def <T> UnmodifiableIterator<T> filterFixedHelper(Iterable<T> unfiltered, Function2<? super T, Iterable<T>, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		if (predicate == null) throw new NullPointerException();
		return new AbstractIterator<T>() {
			val iterator = unfiltered.iterator
			override protected T computeNext() {
				while (iterator.hasNext()) {
					val T element = iterator.next();
					if (predicate.apply(element, unfiltered)) {
						return element;
					}
				}
				return endOfData();
			}
		};
  	}
	
	public static def <T> Iterable<T> filterFixed (Iterable<T> unfiltered, Function2<? super T, Iterable<T>, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		return new FluentIterable<T>() {
			override public Iterator<T> iterator() {
				return filterFixedHelper(unfiltered, predicate);
			}
		}
	}
	
	
	private static def filterFixedHelper(Node unfiltered, Function2<Object, Node, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		if (predicate == null) throw new NullPointerException();
		return new AbstractIterator<Object>() {
			val iterator = unfiltered.iterator
			override protected computeNext() {
				while (iterator.hasNext()) {
					val Object element = iterator.next();
					println("hello")
					if (predicate.apply(element, unfiltered)) {
						return element;
					}
				}
				return endOfData();
			}
		};
  	}
	
	public static def filterFixed (Node unfiltered, Function2<Object, Node, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		return new FluentIterable<Object>() {
			override public Iterator<Object> iterator() {
				return filterFixedHelper(unfiltered, predicate);
			}
		}
	}
	
	
	public static def <T,U> U pipe(T it, Function1<? super T, U> f) {
		f.apply(it)
	}
}