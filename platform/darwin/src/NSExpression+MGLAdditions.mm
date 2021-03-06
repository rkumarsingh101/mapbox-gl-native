#import "NSExpression+MGLPrivateAdditions.h"

#import "MGLTypes.h"
#if TARGET_OS_IPHONE
    #import "UIColor+MGLAdditions.h"
    #define MGLEdgeInsets UIEdgeInsets
#else
    #import "NSColor+MGLAdditions.h"
    #define MGLEdgeInsets NSEdgeInsets
#endif
#import "NSPredicate+MGLAdditions.h"
#import "NSValue+MGLStyleAttributeAdditions.h"
#import "MGLVectorTileSource_Private.h"

#import <objc/runtime.h>

#import <mbgl/style/expression/expression.hpp>

const MGLExpressionInterpolationMode MGLExpressionInterpolationModeLinear = @"linear";
const MGLExpressionInterpolationMode MGLExpressionInterpolationModeExponential = @"exponential";
const MGLExpressionInterpolationMode MGLExpressionInterpolationModeCubicBezier = @"cubic-bezier";

@interface MGLAftermarketExpressionInstaller: NSObject
@end

@implementation MGLAftermarketExpressionInstaller

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self installFunctions];
    });
}

/**
 Adds to NSExpression’s built-in repertoire of functions.
 */
+ (void)installFunctions {
    Class MGLAftermarketExpressionInstaller = [self class];
    
    // NSExpression’s built-in functions are backed by class methods on a
    // private class, so use a function expression to get at the class.
    // http://funwithobjc.tumblr.com/post/2922267976/using-custom-functions-with-nsexpression
    NSExpression *functionExpression = [NSExpression expressionWithFormat:@"sum({})"];
    NSString *className = NSStringFromClass([functionExpression.operand.constantValue class]);
    
    // Effectively categorize the class with some extra class methods.
    Class NSPredicateUtilities = objc_getMetaClass(className.UTF8String);
#pragma clang push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    #define INSTALL_METHOD(sel) \
        { \
            Method method = class_getInstanceMethod(MGLAftermarketExpressionInstaller, @selector(sel)); \
            class_addMethod(NSPredicateUtilities, @selector(sel), method_getImplementation(method), method_getTypeEncoding(method)); \
        }
    #define INSTALL_CONTROL_STRUCTURE(sel) \
        { \
            Method method = class_getInstanceMethod(MGLAftermarketExpressionInstaller, @selector(sel:)); \
            class_addMethod(NSPredicateUtilities, @selector(sel), method_getImplementation(method), method_getTypeEncoding(method)); \
            class_addMethod(NSPredicateUtilities, @selector(sel:), method_getImplementation(method), method_getTypeEncoding(method)); \
        }
    
    // Install method-like functions, taking the number of arguments implied by
    // the selector name.
    INSTALL_METHOD(mgl_join:);
    INSTALL_METHOD(mgl_round:);
    INSTALL_METHOD(mgl_interpolate:withCurveType:parameters:stops:);
    INSTALL_METHOD(mgl_step:from:stops:);
    INSTALL_METHOD(mgl_coalesce:);
    INSTALL_METHOD(mgl_does:have:);
    INSTALL_METHOD(mgl_acos:);
    INSTALL_METHOD(mgl_cos:);
    INSTALL_METHOD(mgl_asin:);
    INSTALL_METHOD(mgl_sin:);
    INSTALL_METHOD(mgl_atan:);
    INSTALL_METHOD(mgl_tan:);
    INSTALL_METHOD(mgl_log2:);
    
    // Install functions that resemble control structures, taking arbitrary
    // numbers of arguments. Vararg aftermarket functions need to be declared
    // with an explicit and implicit first argument.
    INSTALL_CONTROL_STRUCTURE(MGL_LET);
    INSTALL_CONTROL_STRUCTURE(MGL_MATCH);
    INSTALL_CONTROL_STRUCTURE(MGL_IF);
    INSTALL_CONTROL_STRUCTURE(MGL_FUNCTION);
    
    #undef INSTALL_AFTERMARKET_FN
#pragma clang pop
}

/**
 Joins the given components into a single string by concatenating each component
 in order.
 */
- (NSString *)mgl_join:(NSArray<NSString *> *)components {
    return [components componentsJoinedByString:@""];
}

/**
 Rounds the given number to the nearest integer. If the number is halfway
 between two integers, this method rounds it away from zero.
 */
- (NSNumber *)mgl_round:(NSNumber *)number {
    return @(round(number.doubleValue));
}

/**
  Computes the principal value of the inverse cosine.
 */
- (NSNumber *)mgl_acos:(NSNumber *)number {
    return @(acos(number.doubleValue));
}

/**
 Computes the principal value of the cosine.
 */
- (NSNumber *)mgl_cos:(NSNumber *)number {
    return @(cos(number.doubleValue));
}

/**
 Computes the principal value of the inverse sine.
 */
- (NSNumber *)mgl_asin:(NSNumber *)number {
    return @(asin(number.doubleValue));
}

/**
 Computes the principal value of the sine.
 */
- (NSNumber *)mgl_sin:(NSNumber *)number {
    return @(sin(number.doubleValue));
}

/**
 Computes the principal value of the inverse tangent.
 */
- (NSNumber *)mgl_atan:(NSNumber *)number {
    return @(atan(number.doubleValue));
}

/**
 Computes the principal value of the tangent.
 */
- (NSNumber *)mgl_tan:(NSNumber *)number {
    return @(tan(number.doubleValue));
}

/**
 Computes the logarithm base two of the value.
 */
- (NSNumber *)mgl_log2:(NSNumber *)number {
    return @(log2(number.doubleValue));
}

/**
 A placeholder for a method that evaluates an interpolation expression.
 */
- (id)mgl_interpolate:(id)inputExpression withCurveType:(NSString *)curveType parameters:(NSDictionary *)params stops:(NSDictionary *)stops {
    [NSException raise:NSInvalidArgumentException
                format:@"Interpolation expressions lack underlying Objective-C implementations."];
    return nil;
}

/**
 A placeholder for a method that evaluates a step expression.
 */
- (id)mgl_step:(id)inputExpression from:(id)minimumExpression stops:(NSDictionary *)stops {
    [NSException raise:NSInvalidArgumentException
                format:@"Step expressions lack underlying Objective-C implementations."];
    return nil;
}

/**
 A placeholder for a method that evaluates a coalesce expression.
 */
- (id)mgl_coalesce:(NSArray<NSExpression *> *)elements {
    [NSException raise:NSInvalidArgumentException
                format:@"Coalesce expressions lack underlying Objective-C implementations."];
    return nil;
}

/**
 Returns a Boolean value indicating whether the object has a value for the given
 key.
 */
- (BOOL)mgl_does:(id)object have:(NSString *)key {
    return [object valueForKey:key] != nil;
}

/**
 A placeholder for a method that evaluates an expression based on an arbitrary
 number of variable names and assigned expressions.
 */
- (id)MGL_LET:(NSString *)firstVariableName, ... {
    [NSException raise:NSInvalidArgumentException
                format:@"Assignment expressions lack underlying Objective-C implementations."];
    return nil;
}

/**
 A placeholder for a method that evaluates an expression and returns the matching element.
 */
- (id)MGL_MATCH:(id)firstCondition, ... {
    [NSException raise:NSInvalidArgumentException
                format:@"Assignment expressions lack underlying Objective-C implementations."];
    return nil;
}

/**
 A placeholder for a method that evaluates an expression and returns the matching element.
 */
- (id)MGL_IF:(id)firstCondition, ... {
    va_list argumentList;
    va_start(argumentList, firstCondition);
    
    for (id eachExpression = firstCondition; eachExpression; eachExpression = va_arg(argumentList, id)) {
        if ([eachExpression isKindOfClass:[NSComparisonPredicate class]]) {
            id valueExpression = va_arg(argumentList, id);
            if ([eachExpression evaluateWithObject:nil]) {
                return valueExpression;
            }
        } else {
            return eachExpression;
        }
    }
    va_end(argumentList);
    
    return nil;
}


/**
 A placeholder for a catch-all method that evaluates an arbitrary number of
 arguments as an expression according to the Mapbox Style Specification’s
 expression language.
 */
- (id)MGL_FUNCTION:(id)firstArgument, ... {
    [NSException raise:NSInvalidArgumentException
                format:@"Mapbox GL function expressions lack underlying Objective-C implementations."];
    return nil;
}

@end

@implementation NSExpression (MGLPrivateAdditions)

- (std::vector<mbgl::Value>)mgl_aggregateMBGLValue {
    if ([self.constantValue isKindOfClass:[NSArray class]] || [self.constantValue isKindOfClass:[NSSet class]]) {
        std::vector<mbgl::Value> convertedValues;
        for (id value in self.constantValue) {
            NSExpression *expression = value;
            if (![expression isKindOfClass:[NSExpression class]]) {
                expression = [NSExpression expressionForConstantValue:expression];
            }
            convertedValues.push_back(expression.mgl_constantMBGLValue);
        }
        return convertedValues;
    }
    [NSException raise:NSInvalidArgumentException
                format:@"Constant value expression must contain an array or set."];
    return {};
}

- (mbgl::Value)mgl_constantMBGLValue {
    id value = self.constantValue;
    if ([value isKindOfClass:NSString.class]) {
        return { std::string([(NSString *)value UTF8String]) };
    } else if ([value isKindOfClass:NSNumber.class]) {
        NSNumber *number = (NSNumber *)value;
        if ((strcmp([number objCType], @encode(char)) == 0) ||
            (strcmp([number objCType], @encode(BOOL)) == 0)) {
            // char: 32-bit boolean
            // BOOL: 64-bit boolean
            return { (bool)number.boolValue };
        } else if (strcmp([number objCType], @encode(double)) == 0) {
            // Double values on all platforms are interpreted precisely.
            return { (double)number.doubleValue };
        } else if (strcmp([number objCType], @encode(float)) == 0) {
            // Float values when taken as double introduce precision problems,
            // so warn the user to avoid them. This would require them to
            // explicitly use -[NSNumber numberWithFloat:] arguments anyway.
            // We still do this conversion in order to provide a valid value.
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSLog(@"Float value in expression will be converted to a double; some imprecision may result. "
                      @"Use double values explicitly when specifying constant expression values and "
                      @"when specifying arguments to predicate and expression format strings. "
                      @"This will be logged only once.");
            });
            return { (double)number.doubleValue };
        } else if ([number compare:@(0)] == NSOrderedDescending ||
                   [number compare:@(0)] == NSOrderedSame) {
            // Positive integer or zero; use uint64_t per mbgl::Value definition.
            // We use unsigned long long here to avoid any truncation.
            return { (uint64_t)number.unsignedLongLongValue };
        } else if ([number compare:@(0)] == NSOrderedAscending) {
            // Negative integer; use int64_t per mbgl::Value definition.
            // We use long long here to avoid any truncation.
            return { (int64_t)number.longLongValue };
        }
    } else if ([value isKindOfClass:[MGLColor class]]) {
        auto hexString = [(MGLColor *)value mgl_color].stringify();
        return { hexString };
    } else if (value && value != [NSNull null]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Can’t convert %s:%@ to mbgl::Value", [value objCType], value];
    }
    return {};
}

- (std::vector<mbgl::FeatureType>)mgl_aggregateFeatureType {
    if ([self.constantValue isKindOfClass:[NSArray class]] || [self.constantValue isKindOfClass:[NSSet class]]) {
        std::vector<mbgl::FeatureType> convertedValues;
        for (id value in self.constantValue) {
            NSExpression *expression = value;
            if (![expression isKindOfClass:[NSExpression class]]) {
                expression = [NSExpression expressionForConstantValue:expression];
            }
            convertedValues.push_back(expression.mgl_featureType);
        }
        return convertedValues;
    }
    [NSException raise:NSInvalidArgumentException
                format:@"Constant value expression must contain an array or set."];
    return {};
}

- (mbgl::FeatureType)mgl_featureType {
    id value = self.constantValue;
    if ([value isKindOfClass:NSString.class]) {
        if ([value isEqualToString:@"Point"]) {
            return mbgl::FeatureType::Point;
        }
        if ([value isEqualToString:@"LineString"]) {
            return mbgl::FeatureType::LineString;
        }
        if ([value isEqualToString:@"Polygon"]) {
            return mbgl::FeatureType::Polygon;
        }
    } else if ([value isKindOfClass:NSNumber.class]) {
        switch ([value integerValue]) {
            case 1:
                return mbgl::FeatureType::Point;
            case 2:
                return mbgl::FeatureType::LineString;
            case 3:
                return mbgl::FeatureType::Polygon;
            default:
                break;
        }
    }
    return mbgl::FeatureType::Unknown;
}

- (std::vector<mbgl::FeatureIdentifier>)mgl_aggregateFeatureIdentifier {
    if ([self.constantValue isKindOfClass:[NSArray class]] || [self.constantValue isKindOfClass:[NSSet class]]) {
        std::vector<mbgl::FeatureIdentifier> convertedValues;
        for (id value in self.constantValue) {
            NSExpression *expression = value;
            if (![expression isKindOfClass:[NSExpression class]]) {
                expression = [NSExpression expressionForConstantValue:expression];
            }
            convertedValues.push_back(expression.mgl_featureIdentifier);
        }
        return convertedValues;
    }
    [NSException raise:NSInvalidArgumentException
                format:@"Constant value expression must contain an array or set."];
    return {};
}

- (mbgl::FeatureIdentifier)mgl_featureIdentifier {
    mbgl::Value mbglValue = self.mgl_constantMBGLValue;

    if (mbglValue.is<std::string>()) {
        return mbglValue.get<std::string>();
    }
    if (mbglValue.is<double>()) {
        return mbglValue.get<double>();
    }
    if (mbglValue.is<uint64_t>()) {
        return mbglValue.get<uint64_t>();
    }
    if (mbglValue.is<int64_t>()) {
        return mbglValue.get<int64_t>();
    }

    return {};
}

// Selectors of functions that can contain tokens in arguments.
static NSArray * const MGLTokenizedFunctions = @[
    @"mgl_interpolateWithCurveType:parameters:stops:",
    @"mgl_interpolate:withCurveType:parameters:stops:",
    @"mgl_stepWithMinimum:stops:",
    @"mgl_step:from:stops:",
];

/**
 Returns a copy of the given collection with tokens replaced by key path
 expressions.
 
 If no replacements take place, this method returns the original collection.
 */
NSArray<NSExpression *> *MGLCollectionByReplacingTokensWithKeyPaths(NSArray<NSExpression *> *collection) {
    __block NSMutableArray *upgradedCollection;
    [collection enumerateObjectsUsingBlock:^(NSExpression * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSExpression *upgradedItem = item.mgl_expressionByReplacingTokensWithKeyPaths;
        if (upgradedItem != item) {
            if (!upgradedCollection) {
                upgradedCollection = [collection mutableCopy];
            }
            upgradedCollection[idx] = upgradedItem;
        }
    }];
    return upgradedCollection ?: collection;
};

/**
 Returns a copy of the given stop dictionary with tokens replaced by key path
 expressions.
 
 If no replacements take place, this method returns the original stop
 dictionary.
 */
NSDictionary<NSNumber *, NSExpression *> *MGLStopDictionaryByReplacingTokensWithKeyPaths(NSDictionary<NSNumber *, NSExpression *> *stops) {
    __block NSMutableDictionary *upgradedStops;
    [stops enumerateKeysAndObjectsUsingBlock:^(id _Nonnull zoomLevel, NSExpression * _Nonnull value, BOOL * _Nonnull stop) {
        if (![value isKindOfClass:[NSExpression class]]) {
            value = [NSExpression expressionForConstantValue:value];
        }
        NSExpression *upgradedValue = value.mgl_expressionByReplacingTokensWithKeyPaths;
        if (upgradedValue != value) {
            if (!upgradedStops) {
                upgradedStops = [stops mutableCopy];
            }
            upgradedStops[zoomLevel] = upgradedValue;
        }
    }];
    return upgradedStops ?: stops;
};

- (NSExpression *)mgl_expressionByReplacingTokensWithKeyPaths {
    switch (self.expressionType) {
        case NSConstantValueExpressionType: {
            NSString *constantValue = self.constantValue;
            if ([constantValue isKindOfClass:[NSString class]] &&
                [constantValue containsString:@"{"] && [constantValue containsString:@"}"]) {
                NSMutableArray *components = [NSMutableArray array];
                NSScanner *scanner = [NSScanner scannerWithString:constantValue];
                scanner.charactersToBeSkipped = nil;
                while (!scanner.isAtEnd) {
                    NSString *string;
                    if ([scanner scanUpToString:@"{" intoString:&string]) {
                        [components addObject:[NSExpression expressionForConstantValue:string]];
                    }
                    
                    NSString *token;
                    if ([scanner scanString:@"{" intoString:NULL]
                        && [scanner scanUpToString:@"}" intoString:&token]
                        && [scanner scanString:@"}" intoString:NULL]) {
                        [components addObject:[NSExpression expressionForKeyPath:token]];
                    }
                }
                if (components.count == 1) {
                    return components.firstObject;
                }
                return [NSExpression expressionForFunction:@"mgl_join:"
                                                 arguments:@[[NSExpression expressionForAggregate:components]]];
            }
            NSDictionary *stops = self.constantValue;
            if ([stops isKindOfClass:[NSDictionary class]]) {
                NSDictionary *localizedStops = MGLStopDictionaryByReplacingTokensWithKeyPaths(stops);
                if (localizedStops != stops) {
                    return [NSExpression expressionForConstantValue:localizedStops];
                }
            }
            return self;
        }
            
        case NSFunctionExpressionType: {
            if ([MGLTokenizedFunctions containsObject:self.function]) {
                NSArray *arguments = self.arguments;
                NSArray *localizedArguments = MGLCollectionByReplacingTokensWithKeyPaths(arguments);
                if (localizedArguments != arguments) {
                    return [NSExpression expressionForFunction:self.operand selectorName:self.function arguments:localizedArguments];
                }
            }
            return self;
        }
            
        default:
            return self;
    }
}

@end

@implementation NSObject (MGLExpressionAdditions)

- (NSNumber *)mgl_number {
    return nil;
}

- (NSNumber *)mgl_numberWithFallbackValues:(id)fallbackValue, ... {
    if (self.mgl_number) {
        return self.mgl_number;
    }
    
    va_list fallbackValues;
    va_start(fallbackValues, fallbackValue);
    for (id value = fallbackValue; value; value = va_arg(fallbackValues, id)) {
        if ([value mgl_number]) {
            return [value mgl_number];
        }
    }
    
    return nil;
}

@end

@implementation NSNull (MGLExpressionAdditions)

- (id)mgl_jsonExpressionObject {
    return self;
}

@end

@implementation NSString (MGLExpressionAdditions)

- (id)mgl_jsonExpressionObject {
    return self;
}

- (NSNumber *)mgl_number {
    if (self.doubleValue || ![[NSDecimalNumber decimalNumberWithString:self] isEqual:[NSDecimalNumber notANumber]]) {
        return @(self.doubleValue);
    }
    
    return nil;
}

@end

@implementation NSNumber (MGLExpressionAdditions)

- (id)mgl_interpolateWithCurveType:(NSString *)curveType
                        parameters:(NSArray *)parameters
                             stops:(NSDictionary<NSNumber *, id> *)stops {
    [NSException raise:NSInvalidArgumentException
                format:@"Interpolation expressions lack underlying Objective-C implementations."];
    return nil;
}

- (id)mgl_stepWithMinimum:(id)minimum stops:(NSDictionary<NSNumber *, id> *)stops {
    [NSException raise:NSInvalidArgumentException
                format:@"Interpolation expressions lack underlying Objective-C implementations."];
    return nil;
}

- (NSNumber *)mgl_number {
    return self;
}

- (id)mgl_jsonExpressionObject {
    if ([self isEqualToNumber:@(M_E)]) {
        return @[@"e"];
    } else if ([self isEqualToNumber:@(M_PI)]) {
        return @[@"pi"];
    }
    return self;
}

@end

@implementation MGLColor (MGLExpressionAdditions)

- (id)mgl_jsonExpressionObject {
    auto color = [self mgl_color];
    if (color.a == 1) {
        return @[@"rgb", @(color.r * 255), @(color.g * 255), @(color.b * 255)];
    }
    return @[@"rgba", @(color.r * 255), @(color.g * 255), @(color.b * 255), @(color.a)];
}

@end

@implementation NSArray (MGLExpressionAdditions)

- (id)mgl_jsonExpressionObject {
    return [self valueForKeyPath:@"mgl_jsonExpressionObject"];
}

- (id)mgl_coalesce {
    [NSException raise:NSInvalidArgumentException
                      format:@"Coalesce expressions lack underlying Objective-C implementations."];
    return nil;
}

@end

@implementation NSDictionary (MGLExpressionAdditions)

- (id)mgl_jsonExpressionObject {
    NSMutableDictionary *expressionObject = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        expressionObject[[key mgl_jsonExpressionObject]] = [obj mgl_jsonExpressionObject];
    }];
    
    return expressionObject;
}

- (id)mgl_has:(id)element {
    [NSException raise:NSInvalidArgumentException
                format:@"Has expressions lack underlying Objective-C implementations."];
    return nil;

}

@end

@implementation NSExpression (MGLExpressionAdditions)

- (NSExpression *)mgl_expressionWithContext:(NSDictionary<NSString *, NSExpression *> *)context {
    [NSException raise:NSInternalInconsistencyException
                format:@"Assignment expressions lack underlying Objective-C implementations."];
    return self;
}

- (id)mgl_has:(id)element {
    [NSException raise:NSInvalidArgumentException
                format:@"Has expressions lack underlying Objective-C implementations."];
    return nil;
}

@end

@implementation NSExpression (MGLAdditions)

+ (NSExpression *)zoomLevelVariableExpression {
    return [NSExpression expressionForVariable:@"zoomLevel"];
}

+ (NSExpression *)heatmapDensityVariableExpression {
    return [NSExpression expressionForVariable:@"heatmapDensity"];
}

+ (NSExpression *)geometryTypeVariableExpression {
    return [NSExpression expressionForVariable:@"geometryType"];
}

+ (NSExpression *)featureIdentifierVariableExpression {
    return [NSExpression expressionForVariable:@"featureIdentifier"];
}

+ (NSExpression *)featureAttributesVariableExpression {
    return [NSExpression expressionForVariable:@"featureAttributes"];
}

+ (NSExpression *)featurePropertiesVariableExpression {
    return [self featureAttributesVariableExpression];
}

+ (instancetype)mgl_expressionForConditional:(nonnull NSPredicate *)conditionPredicate trueExpression:(nonnull NSExpression *)trueExpression falseExpresssion:(nonnull NSExpression *)falseExpression {
    return [NSExpression expressionForConditional:conditionPredicate trueExpression:trueExpression falseExpression:falseExpression];
}

+ (instancetype)mgl_expressionForSteppingExpression:(nonnull NSExpression *)steppingExpression fromExpression:(nonnull NSExpression *)minimumExpression stops:(nonnull NSExpression *)stops {
    return [NSExpression expressionForFunction:@"mgl_step:from:stops:"
                                     arguments:@[steppingExpression, minimumExpression, stops]];
}

+ (instancetype)mgl_expressionForInterpolatingExpression:(nonnull NSExpression *)inputExpression withCurveType:(nonnull MGLExpressionInterpolationMode)curveType parameters:(nullable NSExpression *)parameters stops:(nonnull NSExpression *)stops {
    NSExpression *sanitizeParams = parameters ? parameters : [NSExpression expressionForConstantValue:nil];
    return [NSExpression expressionForFunction:@"mgl_interpolate:withCurveType:parameters:stops:"
                                     arguments:@[inputExpression, [NSExpression expressionForConstantValue:curveType], sanitizeParams, stops]];
}

+ (instancetype)mgl_expressionForMatchingExpression:(nonnull NSExpression *)inputExpression inDictionary:(nonnull NSDictionary<NSExpression *, NSExpression *> *)matchedExpressions defaultExpression:(nonnull NSExpression *)defaultExpression {
    NSMutableArray *optionsArray = [NSMutableArray arrayWithObjects:inputExpression, nil];
    
    NSEnumerator *matchEnumerator = matchedExpressions.keyEnumerator;
    while (NSExpression *key = matchEnumerator.nextObject) {
        [optionsArray addObject:key];
        [optionsArray addObject:[matchedExpressions objectForKey:key]];
    }
    
    [optionsArray addObject:defaultExpression];
    return [NSExpression expressionForFunction:@"MGL_MATCH"
                                     arguments:optionsArray];
}

- (instancetype)mgl_expressionByAppendingExpression:(nonnull NSExpression *)expression {
    NSExpression *subexpression = [NSExpression expressionForAggregate:@[self, expression]];
    return [NSExpression expressionForFunction:@"mgl_join:" arguments:@[subexpression]];
}

static NSDictionary<NSString *, NSString *> *MGLFunctionNamesByExpressionOperator;
static NSDictionary<NSString *, NSString *> *MGLExpressionOperatorsByFunctionNames;

NSArray *MGLSubexpressionsWithJSONObjects(NSArray *objects) {
    NSMutableArray *subexpressions = [NSMutableArray arrayWithCapacity:objects.count];
    for (id object in objects) {
        NSExpression *expression = [NSExpression expressionWithMGLJSONObject:object];
        [subexpressions addObject:expression];
    }
    return subexpressions;
}

+ (instancetype)expressionWithMGLJSONObject:(id)object {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MGLFunctionNamesByExpressionOperator = @{
            @"+": @"add:to:",
            @"-": @"from:subtract:",
            @"*": @"multiply:by:",
            @"/": @"divide:by:",
            @"%": @"modulus:by:",
            @"sqrt": @"sqrt:",
            @"log10": @"log:",
            @"ln": @"ln:",
            @"abs": @"abs:",
            @"round": @"mgl_round:",
            @"acos" : @"mgl_acos:",
            @"cos" : @"mgl_cos:",
            @"asin" : @"mgl_asin:",
            @"sin" : @"mgl_sin:",
            @"atan" : @"mgl_atan:",
            @"tan" : @"mgl_tan:",
            @"log2" : @"mgl_log2:",
            @"floor": @"floor:",
            @"ceil": @"ceiling:",
            @"^": @"raise:toPower:",
            @"upcase": @"uppercase:",
            @"downcase": @"lowercase:",
            @"let": @"MGL_LET",
        };
    });
    
    if (!object || object == [NSNull null]) {
        return [NSExpression expressionForConstantValue:nil];
    }
    
    if ([object isKindOfClass:[NSString class]] ||
        [object isKindOfClass:[NSNumber class]] ||
        [object isKindOfClass:[NSValue class]] ||
        [object isKindOfClass:[MGLColor class]]) {
        return [NSExpression expressionForConstantValue:object];
    }
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[object count]];
        [object enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
            dictionary[key] = [NSExpression expressionWithMGLJSONObject:obj];
        }];
        return [NSExpression expressionForConstantValue:dictionary];
    }
    
    if ([object isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)object;
        NSString *op = array.firstObject;
        
        NSArray *argumentObjects = [array subarrayWithRange:NSMakeRange(1, array.count - 1)];
        
        NSString *functionName = MGLFunctionNamesByExpressionOperator[op];
        if (functionName) {
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(argumentObjects);
            if ([op isEqualToString:@"+"] && argumentObjects.count > 2) {
                NSExpression *subexpression = [NSExpression expressionForAggregate:subexpressions];
                return [NSExpression expressionForFunction:@"sum:"
                                                 arguments:@[subexpression]];
            } else if ([op isEqualToString:@"^"] && [argumentObjects.firstObject isEqual:@[@"e"]]) {
                functionName = @"exp:";
                subexpressions = [subexpressions subarrayWithRange:NSMakeRange(1, subexpressions.count - 1)];
            }
            
            return [NSExpression expressionForFunction:functionName
                                             arguments:subexpressions];
        } else if ([op isEqualToString:@"literal"]) {
            if ([argumentObjects.firstObject isKindOfClass:[NSArray class]]) {
                return [NSExpression expressionForAggregate:MGLSubexpressionsWithJSONObjects(argumentObjects.firstObject)];
            }
            return [NSExpression expressionWithMGLJSONObject:argumentObjects.firstObject];
        } else if ([op isEqualToString:@"to-boolean"]) {
            NSExpression *operand = [NSExpression expressionWithMGLJSONObject:argumentObjects.firstObject];
            return [NSExpression expressionForFunction:operand selectorName:@"boolValue" arguments:@[]];
        } else if ([op isEqualToString:@"to-number"] || [op isEqualToString:@"number"]) {
            NSExpression *operand = [NSExpression expressionWithMGLJSONObject:argumentObjects.firstObject];
            if (argumentObjects.count == 1) {
                return [NSExpression expressionWithFormat:@"CAST(%@, 'NSNumber')", operand];
            }
            argumentObjects = [argumentObjects subarrayWithRange:NSMakeRange(1, argumentObjects.count - 1)];
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(argumentObjects);
            return [NSExpression expressionForFunction:operand selectorName:@"mgl_numberWithFallbackValues:" arguments:subexpressions];
        } else if ([op isEqualToString:@"to-string"] || [op isEqualToString:@"string"]) {
            NSExpression *operand = [NSExpression expressionWithMGLJSONObject:argumentObjects.firstObject];
            return [NSExpression expressionWithFormat:@"CAST(%@, 'NSString')", operand];
        } else if ([op isEqualToString:@"get"]) {
            if (argumentObjects.count == 2) {
                NSExpression *operand = [NSExpression expressionWithMGLJSONObject:argumentObjects.lastObject];
                if ([argumentObjects.firstObject isKindOfClass:[NSString class]]) {
                    return [NSExpression expressionWithFormat:@"%@.%K", operand, argumentObjects.firstObject];
                }
                NSExpression *key = [NSExpression expressionWithMGLJSONObject:argumentObjects.firstObject];
                return [NSExpression expressionWithFormat:@"%@.%@", operand, key];
            }
            return [NSExpression expressionForKeyPath:argumentObjects.firstObject];
        } else if ([op isEqualToString:@"length"]) {
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(argumentObjects);
            NSString *function = @"count:";
            if ([subexpressions.firstObject expressionType] == NSConstantValueExpressionType
                && [[subexpressions.firstObject constantValue] isKindOfClass:[NSString class]]) {
                function = @"length:";
            }
            return [NSExpression expressionForFunction:function arguments:@[subexpressions.firstObject]];
        } else if ([op isEqualToString:@"rgb"]) {
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(argumentObjects);
            return [NSExpression mgl_expressionForRGBComponents:subexpressions];
        } else if ([op isEqualToString:@"rgba"]) {
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(argumentObjects);
            return [NSExpression mgl_expressionForRGBAComponents:subexpressions];
        } else if ([op isEqualToString:@"min"]) {
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(argumentObjects);
            NSExpression *subexpression = [NSExpression expressionForAggregate:subexpressions];
            return [NSExpression expressionForFunction:@"min:" arguments:@[subexpression]];
        } else if ([op isEqualToString:@"max"]) {
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(argumentObjects);
            NSExpression *subexpression = [NSExpression expressionForAggregate:subexpressions];
            return [NSExpression expressionForFunction:@"max:" arguments:@[subexpression]];
        } else if ([op isEqualToString:@"e"]) {
            return [NSExpression expressionForConstantValue:@(M_E)];
        } else if ([op isEqualToString:@"pi"]) {
            return [NSExpression expressionForConstantValue:@(M_PI)];
        } else if ([op isEqualToString:@"concat"]) {
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(argumentObjects);
            NSExpression *subexpression = [NSExpression expressionForAggregate:subexpressions];
            return [NSExpression expressionForFunction:@"mgl_join:" arguments:@[subexpression]];
        }  else if ([op isEqualToString:@"at"]) {
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(argumentObjects);
            NSExpression *index = subexpressions.firstObject;
            NSExpression *operand = subexpressions[1];
            return [NSExpression expressionForFunction:@"objectFrom:withIndex:" arguments:@[operand, index]];
        } else if ([op isEqualToString:@"has"]) {
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(argumentObjects);
            NSExpression *operand = argumentObjects.count > 1 ? subexpressions[1] : [NSExpression expressionForEvaluatedObject];
            NSExpression *key = subexpressions.firstObject;
            return [NSExpression expressionForFunction:@"mgl_does:have:" arguments:@[operand, key]];
        } else if ([op isEqualToString:@"interpolate"]) {
            NSArray *interpolationOptions = argumentObjects.firstObject;
            NSString *curveType = interpolationOptions.firstObject;
            NSExpression *curveTypeExpression = [NSExpression expressionWithMGLJSONObject:curveType];
            id curveParameters;
            if ([curveType isEqual:@"exponential"]) {
                curveParameters = interpolationOptions[1];
            } else if ([curveType isEqualToString:@"cubic-bezier"]) {
                curveParameters = @[@"literal", [interpolationOptions subarrayWithRange:NSMakeRange(1, 4)]];
            }
            NSExpression *curveParameterExpression = [NSExpression expressionWithMGLJSONObject:curveParameters];
            argumentObjects = [argumentObjects subarrayWithRange:NSMakeRange(1, argumentObjects.count - 1)];
            NSExpression *inputExpression = [NSExpression expressionWithMGLJSONObject:argumentObjects.firstObject];
            NSArray *stopExpressions = [argumentObjects subarrayWithRange:NSMakeRange(1, argumentObjects.count - 1)];
            NSMutableDictionary *stops = [NSMutableDictionary dictionaryWithCapacity:stopExpressions.count / 2];
            NSEnumerator *stopEnumerator = stopExpressions.objectEnumerator;
            while (NSNumber *key = stopEnumerator.nextObject) {
                NSExpression *valueExpression = stopEnumerator.nextObject;
                stops[key] = [NSExpression expressionWithMGLJSONObject:valueExpression];
            }
            NSExpression *stopExpression = [NSExpression expressionForConstantValue:stops];
            return [NSExpression expressionForFunction:@"mgl_interpolate:withCurveType:parameters:stops:"
                                             arguments:@[inputExpression, curveTypeExpression, curveParameterExpression, stopExpression]];
        } else if ([op isEqualToString:@"step"]) {
            NSExpression *inputExpression = [NSExpression expressionWithMGLJSONObject:argumentObjects[0]];
            NSArray *stopExpressions = [argumentObjects subarrayWithRange:NSMakeRange(1, argumentObjects.count - 1)];
            NSExpression *minimum;
            if (stopExpressions.count % 2) {
                minimum = [NSExpression expressionWithMGLJSONObject:stopExpressions.firstObject];
                stopExpressions = [stopExpressions subarrayWithRange:NSMakeRange(1, stopExpressions.count - 1)];
            }
            NSMutableDictionary *stops = [NSMutableDictionary dictionaryWithCapacity:stopExpressions.count / 2];
            NSEnumerator *stopEnumerator = stopExpressions.objectEnumerator;
            while (NSNumber *key = stopEnumerator.nextObject) {
                NSExpression *valueExpression = stopEnumerator.nextObject;
                if (minimum) {
                    stops[key] = [NSExpression expressionWithMGLJSONObject:valueExpression];
                } else {
                    minimum = [NSExpression expressionWithMGLJSONObject:valueExpression];
                }
            }
            NSExpression *stopExpression = [NSExpression expressionForConstantValue:stops];
            return [NSExpression expressionForFunction:@"mgl_step:from:stops:"
                                             arguments:@[inputExpression, minimum, stopExpression]];
        } else if ([op isEqualToString:@"zoom"]) {
            return NSExpression.zoomLevelVariableExpression;
        } else if ([op isEqualToString:@"heatmap-density"]) {
            return NSExpression.heatmapDensityVariableExpression;
        } else if ([op isEqualToString:@"geometry-type"]) {
            return NSExpression.geometryTypeVariableExpression;
        } else if ([op isEqualToString:@"id"]) {
            return NSExpression.featureIdentifierVariableExpression;
        }  else if ([op isEqualToString:@"properties"]) {
            return NSExpression.featureAttributesVariableExpression;
        } else if ([op isEqualToString:@"var"]) {
            return [NSExpression expressionForVariable:argumentObjects.firstObject];
        } else if ([op isEqualToString:@"case"]) {
            NSMutableArray *arguments = [NSMutableArray array];
            
            for (NSUInteger index = 0; index < argumentObjects.count; index++) {
                if (index % 2 == 0 && index != argumentObjects.count - 1) {
                    NSPredicate *predicate = [NSPredicate mgl_predicateWithJSONObject:argumentObjects[index]];
                    NSExpression *argument = [NSExpression expressionForConstantValue:predicate];
                    [arguments addObject:argument];
                } else {
                    [arguments addObject:[NSExpression expressionWithMGLJSONObject:argumentObjects[index]]];
                }
            }

            if (arguments.count == 3) {
                NSPredicate *conditional = [arguments.firstObject constantValue];
                return [NSExpression expressionForConditional:conditional trueExpression:arguments[1] falseExpression:arguments[2]];
            }
            return [NSExpression expressionForFunction:@"MGL_IF" arguments:arguments];
        } else if ([op isEqualToString:@"match"]) {
            NSMutableArray *optionsArray = [NSMutableArray array];
            NSEnumerator *optionsEnumerator = argumentObjects.objectEnumerator;
            while (id object = optionsEnumerator.nextObject) {
                NSExpression *option = [NSExpression expressionWithMGLJSONObject:object];
                [optionsArray addObject:option];
            }
        
            return [NSExpression expressionForFunction:@"MGL_MATCH"
                                             arguments:optionsArray];
        } else if ([op isEqualToString:@"coalesce"]) {
            NSMutableArray *expressions = [NSMutableArray array];
            for (id operand in argumentObjects) {
                [expressions addObject:[NSExpression expressionWithMGLJSONObject:operand]];
            }
            
            return [NSExpression expressionWithFormat:@"mgl_coalesce(%@)", expressions];
        } else {
            NSArray *subexpressions = MGLSubexpressionsWithJSONObjects(array);
            return [NSExpression expressionForFunction:@"MGL_FUNCTION" arguments:subexpressions];
        }
    }
    
    [NSException raise:NSInvalidArgumentException
                format:@"Unable to convert JSON object %@ to an NSExpression.", object];
    
    return nil;
}

- (id)mgl_jsonExpressionObject {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MGLExpressionOperatorsByFunctionNames = @{
            @"add:to:": @"+",
            @"from:subtract:": @"-",
            @"multiply:by:": @"*",
            @"divide:by:": @"/",
            @"modulus:by:": @"%",
            @"sqrt:": @"sqrt",
            @"log:": @"log10",
            @"ln:": @"ln",
            @"raise:toPower:": @"^",
            @"ceiling:": @"ceil",
            @"abs:": @"abs",
            @"floor:": @"floor",
            @"uppercase:": @"upcase",
            @"lowercase:": @"downcase",
            @"length:": @"length",
            @"mgl_round:": @"round",
            @"mgl_acos:" : @"acos",
            @"mgl_cos:" : @"cos",
            @"mgl_asin:" : @"asin",
            @"mgl_sin:" : @"sin",
            @"mgl_atan:" : @"atan",
            @"mgl_tan:" : @"tan",
            @"mgl_log2:" : @"log2",
            // Vararg aftermarket expressions need to be declared with an explicit and implicit first argument.
            @"MGL_LET": @"let",
            @"MGL_LET:": @"let",
        };
    });
    
    switch (self.expressionType) {
        case NSVariableExpressionType: {
            if ([self.variable isEqualToString:@"heatmapDensity"]) {
                return @[@"heatmap-density"];
            }
            if ([self.variable isEqualToString:@"zoomLevel"]) {
                return @[@"zoom"];
            }
            if ([self.variable isEqualToString:@"geometryType"]) {
                return @[@"geometry-type"];
            }
            if ([self.variable isEqualToString:@"featureIdentifier"]) {
                return @[@"id"];
            }
            if ([self.variable isEqualToString:@"featureAttributes"]) {
                return @[@"properties"];
            }
            return @[@"var", self.variable];
        }
        
        case NSConstantValueExpressionType: {
            id constantValue = self.constantValue;
            if (!constantValue || constantValue == [NSNull null]) {
                return [NSNull null];
            }
            if ([constantValue isEqual:@(M_E)]) {
                return @[@"e"];
            }
            if ([constantValue isEqual:@(M_PI)]) {
                return @[@"pi"];
            }
            if ([constantValue isKindOfClass:[NSArray class]] ||
                [constantValue isKindOfClass:[NSDictionary class]]) {
                NSArray *collection = [constantValue mgl_jsonExpressionObject];
                return @[@"literal", collection];
            }
            if ([constantValue isKindOfClass:[MGLColor class]]) {
                auto color = [constantValue mgl_color];
                if (color.a == 1) {
                    return @[@"rgb", @(color.r * 255), @(color.g * 255), @(color.b * 255)];
                }
                return @[@"rgba", @(color.r * 255), @(color.g * 255), @(color.b * 255), @(color.a)];
            }
            if ([constantValue isKindOfClass:[NSValue class]]) {
                const auto boxedValue = (NSValue *)constantValue;
                if (strcmp([boxedValue objCType], @encode(CGVector)) == 0) {
                    // offset [x, y]
                    std::array<float, 2> mglValue = boxedValue.mgl_offsetArrayValue;
                    return @[@"literal", @[@(mglValue[0]), @(mglValue[1])]];
                }
                if (strcmp([boxedValue objCType], @encode(MGLEdgeInsets)) == 0) {
                    // padding [x, y]
                    std::array<float, 4> mglValue = boxedValue.mgl_paddingArrayValue;
                    return @[@"literal", @[@(mglValue[0]), @(mglValue[1]), @(mglValue[2]), @(mglValue[3])]];
                }
            }
            return self.constantValue;
        }
            
        case NSKeyPathExpressionType: {
            NSArray *expressionObject;
            for (NSString *pathComponent in self.keyPath.pathComponents.reverseObjectEnumerator) {
                if (expressionObject) {
                    expressionObject = @[@"get", pathComponent, expressionObject];
                } else {
                    expressionObject = @[@"get", pathComponent];
                }
            }
            return expressionObject;
        }
            
        case NSFunctionExpressionType: {
            NSString *function = self.function;
            NSString *op = MGLExpressionOperatorsByFunctionNames[function];
            if (op) {
                NSArray *arguments = self.arguments.mgl_jsonExpressionObject;
                return [@[op] arrayByAddingObjectsFromArray:arguments];
            } else if ([function isEqualToString:@"valueForKey:"] || [function isEqualToString:@"valueForKeyPath:"]) {
                return @[@"get", self.arguments.firstObject.mgl_jsonExpressionObject, self.operand.mgl_jsonExpressionObject];
            } else if ([function isEqualToString:@"average:"]) {
                NSExpression *sum = [NSExpression expressionForFunction:@"sum:" arguments:self.arguments];
                NSExpression *count = [NSExpression expressionForFunction:@"count:" arguments:self.arguments];
                return [NSExpression expressionForFunction:@"divide:by:" arguments:@[sum, count]].mgl_jsonExpressionObject;
            } else if ([function isEqualToString:@"sum:"]) {
                NSArray *arguments = [self.arguments.firstObject.collection valueForKeyPath:@"mgl_jsonExpressionObject"];
                return [@[@"+"] arrayByAddingObjectsFromArray:arguments];
            } else if ([function isEqualToString:@"count:"]) {
                NSArray *arguments = self.arguments.firstObject.mgl_jsonExpressionObject;
                return @[@"length", arguments];
            } else if ([function isEqualToString:@"min:"]) {
                NSArray *arguments = [self.arguments.firstObject.collection valueForKeyPath:@"mgl_jsonExpressionObject"];
                return [@[@"min"] arrayByAddingObjectsFromArray:arguments];
            } else if ([function isEqualToString:@"max:"]) {
                NSArray *arguments = [self.arguments.firstObject.collection valueForKeyPath:@"mgl_jsonExpressionObject"];
                return [@[@"max"] arrayByAddingObjectsFromArray:arguments];
            } else if ([function isEqualToString:@"exp:"]) {
                return [NSExpression expressionForFunction:@"raise:toPower:" arguments:@[@(M_E), self.arguments.firstObject]].mgl_jsonExpressionObject;
            } else if ([function isEqualToString:@"trunc:"]) {
                return [NSExpression expressionWithFormat:@"%@ - modulus:by:(%@, 1)",
                        self.arguments.firstObject, self.arguments.firstObject].mgl_jsonExpressionObject;
            } else if ([function isEqualToString:@"mgl_join:"]) {
                NSArray *arguments = [self.arguments.firstObject.collection valueForKeyPath:@"mgl_jsonExpressionObject"];
                return [@[@"concat"] arrayByAddingObjectsFromArray:arguments];
            } else if ([function isEqualToString:@"stringByAppendingString:"]) {
                NSArray *arguments = self.arguments.mgl_jsonExpressionObject;
                return [@[@"concat", self.operand.mgl_jsonExpressionObject] arrayByAddingObjectsFromArray:arguments];
            } else if ([function isEqualToString:@"objectFrom:withIndex:"]) {
                return @[@"at", self.arguments[1].mgl_jsonExpressionObject, self.arguments[0].mgl_jsonExpressionObject];
            } else if ([function isEqualToString:@"boolValue"]) {
                return @[@"to-boolean", self.operand.mgl_jsonExpressionObject];
            } else if ([function isEqualToString:@"mgl_number"] ||
                       [function isEqualToString:@"mgl_numberWithFallbackValues:"] ||
                       [function isEqualToString:@"decimalValue"] ||
                       [function isEqualToString:@"floatValue"] ||
                       [function isEqualToString:@"doubleValue"]) {
                NSArray *arguments = self.arguments.mgl_jsonExpressionObject;
                return [@[@"to-number", self.operand.mgl_jsonExpressionObject] arrayByAddingObjectsFromArray:arguments];
            } else if ([function isEqualToString:@"stringValue"]) {
                return @[@"to-string", self.operand.mgl_jsonExpressionObject];
            } else if ([function isEqualToString:@"noindex:"]) {
                return self.arguments.firstObject.mgl_jsonExpressionObject;
            } else if ([function isEqualToString:@"mgl_does:have:"] ||
                       [function isEqualToString:@"mgl_has:"]) {
                return self.mgl_jsonHasExpressionObject;
            } else if ([function isEqualToString:@"mgl_interpolate:withCurveType:parameters:stops:"]
                       || [function isEqualToString:@"mgl_interpolateWithCurveType:parameters:stops:"]) {
                return self.mgl_jsonInterpolationExpressionObject;
            } else if ([function isEqualToString:@"mgl_step:from:stops:"]
                       || [function isEqualToString:@"mgl_stepWithMinimum:stops:"]) {
                return self.mgl_jsonStepExpressionObject;
            } else if ([function isEqualToString:@"mgl_expressionWithContext:"]) {
                id context = self.arguments.firstObject;
                if ([context isKindOfClass:[NSExpression class]]) {
                    context = [context constantValue];
                }
                NSMutableArray *expressionObject = [NSMutableArray arrayWithObjects:@"let", nil];
                [context enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, NSExpression * _Nonnull obj, BOOL * _Nonnull stop) {
                    [expressionObject addObject:key];
                    [expressionObject addObject:obj.mgl_jsonExpressionObject];
                }];
                [expressionObject addObject:self.operand.mgl_jsonExpressionObject];
                return expressionObject;
            } else if ([function isEqualToString:@"MGL_IF"] ||
                       [function isEqualToString:@"mgl_if:"]) {
                return self.mgl_jsonIfExpressionObject;
            } else if ([function isEqualToString:@"MGL_MATCH"] ||
                       [function isEqualToString:@"mgl_match:"]) {
                return self.mgl_jsonMatchExpressionObject;
            } else if ([function isEqualToString:@"mgl_coalesce:"] ||
                       [function isEqualToString:@"mgl_coalesce"]) {
                
                return self.mgl_jsonCoalesceExpressionObject;
            } else if ([function isEqualToString:@"castObject:toType:"]) {
                id object = self.arguments.firstObject.mgl_jsonExpressionObject;
                NSString *type = self.arguments[1].mgl_jsonExpressionObject;
                if ([type isEqualToString:@"NSString"]) {
                    return @[@"to-string", object];
                } else if ([type isEqualToString:@"NSNumber"]) {
                    return @[@"to-number", object];
                }
                [NSException raise:NSInvalidArgumentException
                            format:@"Casting expression to %@ not yet implemented.", type];
            } else if ([function isEqualToString:@"MGL_FUNCTION"]) {
                return self.arguments.mgl_jsonExpressionObject;
            } else if (op == [MGLColor class] && [function isEqualToString:@"colorWithRed:green:blue:alpha:"]) {
                NSArray *arguments = self.arguments.mgl_jsonExpressionObject;
                return [@[@"rgba"] arrayByAddingObjectsFromArray:arguments];
            } else if ([function isEqualToString:@"median:"] ||
                       [function isEqualToString:@"mode:"] ||
                       [function isEqualToString:@"stddev:"] ||
                       [function isEqualToString:@"random"] ||
                       [function isEqualToString:@"randomn:"] ||
                       [function isEqualToString:@"now"] ||
                       [function isEqualToString:@"bitwiseAnd:with:"] ||
                       [function isEqualToString:@"bitwiseOr:with:"] ||
                       [function isEqualToString:@"bitwiseXor:with:"] ||
                       [function isEqualToString:@"leftshift:by:"] ||
                       [function isEqualToString:@"rightshift:by:"] ||
                       [function isEqualToString:@"onesComplement:"] ||
                       [function isEqualToString:@"distanceToLocation:fromLocation:"]) {
                [NSException raise:NSInvalidArgumentException
                            format:@"Expression function %@ not yet implemented.", function];
                return nil;
            } else {
                [NSException raise:NSInvalidArgumentException
                            format:@"Unrecognized expression function %@.", function];
                return nil;
            }
        }
            
        case NSConditionalExpressionType: {
            NSMutableArray *arguments = [NSMutableArray arrayWithObjects:self.predicate.mgl_jsonExpressionObject, nil];
            
            if (self.trueExpression.expressionType == NSConditionalExpressionType) {
                // Fold nested conditionals into a single case expression.
                NSArray *trueArguments = self.trueExpression.mgl_jsonExpressionObject;
                trueArguments = [trueArguments subarrayWithRange:NSMakeRange(1, trueArguments.count - 1)];
                [arguments addObjectsFromArray:trueArguments];
            } else {
                [arguments addObject:self.trueExpression.mgl_jsonExpressionObject];
            }
            
            if (self.falseExpression.expressionType == NSConditionalExpressionType) {
                // Fold nested conditionals into a single case expression.
                NSArray *falseArguments = self.falseExpression.mgl_jsonExpressionObject;
                falseArguments = [falseArguments subarrayWithRange:NSMakeRange(1, falseArguments.count - 1)];
                [arguments addObjectsFromArray:falseArguments];
            } else {
                [arguments addObject:self.falseExpression.mgl_jsonExpressionObject];
            }
            
            [arguments insertObject:@"case" atIndex:0];
            return arguments;
        }
            
        case NSAggregateExpressionType: {
            NSArray *collection = [self.collection valueForKeyPath:@"mgl_jsonExpressionObject"];
            return @[@"literal", collection];
        }
        
        case NSEvaluatedObjectExpressionType:
        case NSUnionSetExpressionType:
        case NSIntersectSetExpressionType:
        case NSMinusSetExpressionType:
        case NSSubqueryExpressionType:
        case NSAnyKeyExpressionType:
        case NSBlockExpressionType:
            [NSException raise:NSInvalidArgumentException
                        format:@"Expression type %lu not yet implemented.", self.expressionType];
    }
    
    // NSKeyPathSpecifierExpression
    if (self.expressionType == 10) {
        return self.description;
    }
    // An assignment expression type is present in the BNF grammar, but the
    // corresponding NSExpressionType value and property getters are missing.
    if (self.expressionType == 12) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Assignment expressions not yet implemented."];
    }
    
    return nil;
}

- (id)mgl_jsonInterpolationExpressionObject {
    NSUInteger expectedArgumentCount = [self.function componentsSeparatedByString:@":"].count - 1;
    if (self.arguments.count < expectedArgumentCount) {
        [NSException raise:NSInvalidArgumentException format:
         @"Too few arguments to ‘%@’ function; expected %lu arguments.",
         self.function, expectedArgumentCount];
    } else if (self.arguments.count > expectedArgumentCount) {
        [NSException raise:NSInvalidArgumentException format:
         @"%lu unexpected arguments to ‘%@’ function; expected %lu arguments.",
         self.arguments.count - expectedArgumentCount, self.function, expectedArgumentCount];
    }
    
    BOOL isAftermarketFunction = [self.function isEqualToString:@"mgl_interpolate:withCurveType:parameters:stops:"];
    NSUInteger curveTypeIndex = isAftermarketFunction ? 1 : 0;
    NSString *curveType = self.arguments[curveTypeIndex].constantValue;
    NSMutableArray *interpolationArray = [NSMutableArray arrayWithObject:curveType];
    if ([curveType isEqualToString:@"exponential"]) {
        id base = [self.arguments[curveTypeIndex + 1] mgl_jsonExpressionObject];
        [interpolationArray addObject:base];
    } else if ([curveType isEqualToString:@"cubic-bezier"]) {
        NSArray *controlPoints = [self.arguments[curveTypeIndex + 1].collection mgl_jsonExpressionObject];
        [interpolationArray addObjectsFromArray:controlPoints];
    }
    NSMutableArray *expressionObject = [NSMutableArray arrayWithObjects:@"interpolate", interpolationArray, nil];
    [expressionObject addObject:(isAftermarketFunction ? self.arguments.firstObject : self.operand).mgl_jsonExpressionObject];
    NSDictionary<NSNumber *, NSExpression *> *stops = self.arguments[curveTypeIndex + 2].constantValue;
    for (NSNumber *key in [stops.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        [expressionObject addObject:key];
        [expressionObject addObject:[stops[key] mgl_jsonExpressionObject]];
    }
    return expressionObject;
}

- (id)mgl_jsonStepExpressionObject {
    BOOL isAftermarketFunction = [self.function isEqualToString:@"mgl_step:from:stops:"];
    NSUInteger minimumIndex = isAftermarketFunction ? 1 : 0;
    id minimum = self.arguments[minimumIndex].mgl_jsonExpressionObject;
    NSMutableArray *expressionObject = [NSMutableArray arrayWithObjects:@"step", (isAftermarketFunction ? self.arguments.firstObject : self.operand).mgl_jsonExpressionObject, minimum, nil];
    NSDictionary<NSNumber *, NSExpression *> *stops = self.arguments[minimumIndex + 1].constantValue;
    for (NSNumber *key in [stops.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        [expressionObject addObject:key];
        [expressionObject addObject:[stops[key] mgl_jsonExpressionObject]];
    }
    return expressionObject;
}

- (id)mgl_jsonMatchExpressionObject {
    BOOL isAftermarketFunction = [self.function isEqualToString:@"MGL_MATCH"];
    NSUInteger minimumIndex = isAftermarketFunction ? 1 : 0;

    NSMutableArray *expressionObject = [NSMutableArray arrayWithObjects:@"match", (isAftermarketFunction ? self.arguments.firstObject : self.operand).mgl_jsonExpressionObject, nil];
    NSArray<NSExpression *> *arguments = isAftermarketFunction ? self.arguments : self.arguments[minimumIndex].constantValue;
    
    for (NSUInteger index = minimumIndex; index < arguments.count; index++) {
        [expressionObject addObject:arguments[index].mgl_jsonExpressionObject];
    }
    
    return expressionObject;
}

- (id)mgl_jsonIfExpressionObject {
    BOOL isAftermarketFunction = [self.function isEqualToString:@"MGL_IF"];
    NSUInteger minimumIndex = isAftermarketFunction ? 1 : 0;
    NSExpression *firstCondition;
    id condition;
    
    if (isAftermarketFunction) {
        firstCondition = self.arguments.firstObject;
    } else {
        firstCondition = self.operand;
    }
    
    if ([firstCondition respondsToSelector:@selector(constantValue)] && [firstCondition.constantValue isKindOfClass:[NSComparisonPredicate class]]) {
        NSPredicate *predicate = (NSPredicate *)firstCondition.constantValue;
        condition = predicate.mgl_jsonExpressionObject;
    } else {
        condition = firstCondition.mgl_jsonExpressionObject;
    }
    
    NSMutableArray *expressionObject = [NSMutableArray arrayWithObjects:@"case", condition, nil];
    NSArray<NSExpression *> *arguments = isAftermarketFunction ? self.arguments : self.arguments[minimumIndex].constantValue;
    
    for (NSUInteger index = minimumIndex; index < arguments.count; index++) {
        if ([arguments[index] respondsToSelector:@selector(constantValue)] && [arguments[index].constantValue isKindOfClass:[NSComparisonPredicate class]]) {
            NSPredicate *predicate = (NSPredicate *)arguments[index].constantValue;
            [expressionObject addObject:predicate.mgl_jsonExpressionObject];
        } else {
            [expressionObject addObject:arguments[index].mgl_jsonExpressionObject];
        }
    }
    
    return expressionObject;
}

- (id)mgl_jsonCoalesceExpressionObject {
    BOOL isAftermarketFunction = [self.function isEqualToString:@"mgl_coalesce:"];
    NSMutableArray *expressionObject = [NSMutableArray arrayWithObjects:@"coalesce", nil];
    
    for (NSExpression *expression in  (isAftermarketFunction ? self.arguments.firstObject : self.operand).constantValue) {
        [expressionObject addObject:[expression mgl_jsonExpressionObject]];
    }
    
    return expressionObject;
}

- (id)mgl_jsonHasExpressionObject {
    BOOL isAftermarketFunction = [self.function isEqualToString:@"mgl_does:have:"];
    NSExpression *operand = isAftermarketFunction ? self.arguments[0] : self.operand;
    NSExpression *key = self.arguments[isAftermarketFunction ? 1 : 0];

    NSMutableArray *expressionObject = [NSMutableArray arrayWithObjects:@"has", key.mgl_jsonExpressionObject, nil];
    if (operand.expressionType != NSEvaluatedObjectExpressionType) {
        [expressionObject addObject:operand.mgl_jsonExpressionObject];
    }
    return expressionObject;
}

#pragma mark Localization

/**
 Returns a localized copy of the given collection.
 
 If no localization takes place, this method returns the original collection.
 */
NSArray<NSExpression *> *MGLLocalizedCollection(NSArray<NSExpression *> *collection, NSLocale * _Nullable locale) {
    __block NSMutableArray *localizedCollection;
    [collection enumerateObjectsUsingBlock:^(NSExpression * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        NSExpression *localizedItem = [item mgl_expressionLocalizedIntoLocale:locale];
        if (localizedItem != item) {
            if (!localizedCollection) {
                localizedCollection = [collection mutableCopy];
            }
            localizedCollection[idx] = localizedItem;
        }
    }];
    return localizedCollection ?: collection;
};

/**
 Returns a localized copy of the given stop dictionary.
 
 If no localization takes place, this method returns the original stop
 dictionary.
 */
NSDictionary<NSNumber *, NSExpression *> *MGLLocalizedStopDictionary(NSDictionary<NSNumber *, NSExpression *> *stops, NSLocale * _Nullable locale) {
    __block NSMutableDictionary *localizedStops;
    [stops enumerateKeysAndObjectsUsingBlock:^(id _Nonnull zoomLevel, NSExpression * _Nonnull value, BOOL * _Nonnull stop) {
        if (![value isKindOfClass:[NSExpression class]]) {
            value = [NSExpression expressionForConstantValue:value];
        }
        NSExpression *localizedValue = [value mgl_expressionLocalizedIntoLocale:locale];
        if (localizedValue != value) {
            if (!localizedStops) {
                localizedStops = [stops mutableCopy];
            }
            localizedStops[zoomLevel] = localizedValue;
        }
    }];
    return localizedStops ?: stops;
};

- (NSExpression *)mgl_expressionLocalizedIntoLocale:(nullable NSLocale *)locale {
    switch (self.expressionType) {
        case NSConstantValueExpressionType: {
            NSDictionary *stops = self.constantValue;
            if ([stops isKindOfClass:[NSDictionary class]]) {
                NSDictionary *localizedStops = MGLLocalizedStopDictionary(stops, locale);
                if (localizedStops != stops) {
                    return [NSExpression expressionForConstantValue:localizedStops];
                }
            }
            return self;
        }
            
        case NSKeyPathExpressionType: {
            if ([self.keyPath isEqualToString:@"name"] || [self.keyPath hasPrefix:@"name_"]) {
                NSString *localizedKeyPath = @"name";
                if (![locale.localeIdentifier isEqualToString:@"mul"]) {
                    NSArray *preferences = locale ? @[locale.localeIdentifier] : [NSLocale preferredLanguages];
                    NSString *preferredLanguage = [MGLVectorTileSource preferredMapboxStreetsLanguageForPreferences:preferences];
                    if (preferredLanguage) {
                        localizedKeyPath = [NSString stringWithFormat:@"name_%@", preferredLanguage];
                    }
                }
                return [NSExpression expressionForKeyPath:localizedKeyPath];
            }
            return self;
        }
            
        case NSFunctionExpressionType: {
            NSExpression *operand = self.operand;
            NSExpression *localizedOperand = [operand mgl_expressionLocalizedIntoLocale:locale];
            
            NSArray *arguments = self.arguments;
            NSArray *localizedArguments = MGLLocalizedCollection(arguments, locale);
            if (localizedArguments != arguments) {
                return [NSExpression expressionForFunction:localizedOperand
                                              selectorName:self.function
                                                 arguments:localizedArguments];
            }
            if (localizedOperand != operand) {
                return [NSExpression expressionForFunction:localizedOperand
                                              selectorName:self.function
                                                 arguments:self.arguments];
            }
            return self;
        }
            
        case NSConditionalExpressionType: {
            NSExpression *trueExpression = self.trueExpression;
            NSExpression *localizedTrueExpression = [trueExpression mgl_expressionLocalizedIntoLocale:locale];
            NSExpression *falseExpression = self.falseExpression;
            NSExpression *localizedFalseExpression = [falseExpression mgl_expressionLocalizedIntoLocale:locale];
            if (localizedTrueExpression != trueExpression || localizedFalseExpression != falseExpression) {
                return [NSExpression expressionForConditional:self.predicate
                                               trueExpression:localizedTrueExpression
                                              falseExpression:localizedFalseExpression];
            }
            return self;
        }
            
        case NSAggregateExpressionType: {
            NSArray *collection = self.collection;
            if ([collection isKindOfClass:[NSArray class]]) {
                NSArray *localizedCollection = MGLLocalizedCollection(collection, locale);
                if (localizedCollection != collection) {
                    return [NSExpression expressionForAggregate:localizedCollection];
                }
            }
            return self;
        }
            
        default:
            return self;
    }
}

@end
